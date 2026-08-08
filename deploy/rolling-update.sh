#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

app_service="app"
image_repository="registry.jps.ar:5000/vdp/app"
state_dir="${DEPLOY_STATE_DIR:-$script_dir/.deploy-state}"
state_file="$state_dir/releases"
lock_file="$state_dir/deploy.lock"
health_timeout="${DEPLOY_HEALTH_TIMEOUT:-180}"
stop_timeout="${DEPLOY_STOP_TIMEOUT:-30}"

new_container_id=""
containers_before_rollout=""
rollout_snapshot_taken=false
previous_container_id=""
previous_container_stopped=false
promotion_complete=false
scheduler_was_running=false
scheduler_paused=false

usage() {
  cat <<'USAGE'
Usage:
  rolling-update.sh deploy RELEASE_TAG
  rolling-update.sh rollback [RELEASE_TAG]
  rolling-update.sh releases

Environment:
  DEPLOY_HEALTH_TIMEOUT  Seconds to wait for the new container (default: 180)
  DEPLOY_STOP_TIMEOUT    Seconds to drain the old container (default: 30)
  DEPLOY_STATE_DIR       Persistent release-state directory
USAGE
}

die() {
  echo "Error: $*" >&2
  exit 1
}

validate_positive_integer() {
  local name="$1"
  local value="$2"

  [[ "$value" =~ ^[1-9][0-9]*$ ]] || die "$name must be a positive integer"
}

validate_tag() {
  local tag="$1"

  [[ "$tag" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]] || die "invalid image tag: $tag"
}

state_value() {
  local key="$1"

  [[ -f "$state_file" ]] || return 0
  awk -F= -v key="$key" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "$state_file"
}

write_state() {
  local current="$1"
  local previous="$2"
  local temporary

  temporary="$(mktemp "$state_dir/releases.XXXXXX")"
  printf 'current=%s\nprevious=%s\n' "$current" "$previous" > "$temporary"
  mv "$temporary" "$state_file"
}

running_app_containers() {
  docker compose ps --quiet "$app_service"
}

all_app_containers() {
  docker compose ps --all --quiet "$app_service"
}

line_count() {
  local value="$1"

  if [[ -z "$value" ]]; then
    echo 0
  else
    printf '%s\n' "$value" | wc -l | tr -d ' '
  fi
}

contains_line() {
  local lines="$1"
  local candidate="$2"

  [[ -n "$lines" ]] && grep -Fqx -- "$candidate" <<< "$lines"
}

find_new_container() {
  local before="$1"
  local after="$2"
  local candidate
  local found=""

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if ! contains_line "$before" "$candidate"; then
      [[ -z "$found" ]] || die "more than one new app container was created"
      found="$candidate"
    fi
  done <<< "$after"

  [[ -n "$found" ]] || die "the new app container could not be identified"
  printf '%s\n' "$found"
}

container_image_id() {
  docker inspect --format '{{.Image}}' "$1"
}

bootstrap_current_release() {
  local container_id="$1"
  local current="$2"
  local configured_image
  local configured_tag
  local image_id
  local bootstrap_tag

  if [[ -n "$current" ]]; then
    printf '%s\n' "$current"
    return
  fi

  configured_image="$(docker inspect --format '{{.Config.Image}}' "$container_id")"
  case "$configured_image" in
    "$image_repository":*)
      configured_tag="${configured_image#"$image_repository:"}"
      if [[ "$configured_tag" != "latest" ]] && docker image inspect "$configured_image" >/dev/null 2>&1; then
        echo "Recovered current release $configured_tag from the running container." >&2
        printf '%s\n' "$configured_tag"
        return
      fi
      ;;
  esac

  image_id="$(container_image_id "$container_id")"
  bootstrap_tag="bootstrap-$(date -u +'%Y%m%dT%H%M%SZ')"
  docker image tag "$image_id" "$image_repository:$bootstrap_tag"
  echo "Saved the currently running image as $image_repository:$bootstrap_tag" >&2
  printf '%s\n' "$bootstrap_tag"
}

verify_running_release() {
  local container_id="$1"
  local current="$2"
  local expected_image="$image_repository:$current"
  local running_image_id
  local expected_image_id

  [[ -n "$current" ]] || return 0

  if ! docker image inspect "$expected_image" >/dev/null 2>&1; then
    echo "Recorded current image $expected_image is not available locally; pulling it to verify the running container..." >&2
    docker pull "$expected_image" >/dev/null || \
      die "state points to $current, but that image is unavailable locally and could not be pulled"
  fi

  running_image_id="$(container_image_id "$container_id")"
  expected_image_id="$(docker image inspect --format '{{.Id}}' "$expected_image")"
  [[ "$running_image_id" == "$expected_image_id" ]] || \
    die "the running app image ($running_image_id) does not match the recorded current release $current ($expected_image_id)"
}

scheduler_container() {
  docker compose ps --quiet ofelia 2>/dev/null || true
}

pause_scheduler() {
  if [[ -n "$(scheduler_container)" ]]; then
    scheduler_was_running=true
    scheduler_paused=true
    docker compose stop ofelia
  fi
}

restore_scheduler() {
  if [[ "$scheduler_was_running" == true && "$scheduler_paused" == true ]]; then
    docker compose up -d --force-recreate --no-deps ofelia
    scheduler_paused=false
  fi
}

remove_containers_created_during_rollout() {
  local after
  local candidate

  after="$(all_app_containers 2>/dev/null || true)"
  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if ! contains_line "$containers_before_rollout" "$candidate"; then
      echo "Removing failed app container $candidate..." >&2
      docker logs --tail 200 "$candidate" >&2 || true
      docker container rm --force "$candidate" >/dev/null 2>&1 || true
    fi
  done <<< "$after"
}

cleanup() {
  local status=$?

  set +e
  if (( status != 0 )) && [[ "$promotion_complete" != true ]]; then
    if [[ "$rollout_snapshot_taken" == true ]]; then
      remove_containers_created_during_rollout
    fi
    if [[ "$previous_container_stopped" == true && -n "$previous_container_id" ]]; then
      echo "Restarting previous app container $previous_container_id..." >&2
      docker container start "$previous_container_id" >/dev/null
      previous_container_stopped=false
    fi
  fi
  restore_scheduler
  exit "$status"
}

wait_until_healthy() {
  local container_id="$1"
  local deadline=$((SECONDS + health_timeout))
  local status

  while (( SECONDS < deadline )); do
    status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container_id" 2>/dev/null || echo missing)"
    case "$status" in
      healthy)
        return 0
        ;;
      unhealthy|exited|dead|missing)
        echo "New app container entered state: $status" >&2
        return 1
        ;;
      starting|created|running|restarting)
        sleep 2
        ;;
      *)
        echo "Unexpected app container state: $status" >&2
        return 1
        ;;
    esac
  done

  echo "New app container did not become healthy within ${health_timeout}s" >&2
  return 1
}

pull_release() {
  local allow_local_fallback="$1"

  if docker compose pull "$app_service"; then
    return 0
  fi

  if [[ "$allow_local_fallback" == true ]] && docker image inspect "$image_repository:$APP_IMAGE_TAG" >/dev/null 2>&1; then
    echo "Registry pull failed; using the existing local image for rollback." >&2
    return 0
  fi

  return 1
}

perform_rollout() {
  local target_tag="$1"
  local allow_local_fallback="$2"
  local before_all
  local after_all
  local running
  local running_count
  local all_count
  local old_container_id=""
  local current

  validate_tag "$target_tag"
  export APP_IMAGE_TAG="$target_tag"
  docker compose config --quiet

  running="$(running_app_containers)"
  before_all="$(all_app_containers)"
  containers_before_rollout="$before_all"
  rollout_snapshot_taken=true
  running_count="$(line_count "$running")"
  all_count="$(line_count "$before_all")"

  (( running_count <= 1 )) || die "more than one app container is already running; refusing to choose one"
  (( all_count == running_count )) || die "stopped app containers exist; remove or inspect them before deploying"

  current="$(state_value current)"
  if (( running_count == 1 )); then
    old_container_id="$running"
    previous_container_id="$old_container_id"
    current="$(bootstrap_current_release "$old_container_id" "$current")"
    verify_running_release "$old_container_id" "$current"
  fi

  [[ "$target_tag" != "$current" ]] || die "release $target_tag is already running"

  pull_release "$allow_local_fallback"
  pause_scheduler
  if (( running_count == 1 )); then
    docker compose up -d --no-deps --scale "$app_service=2" --no-recreate "$app_service"
  else
    docker compose up -d --no-deps --scale "$app_service=1" --no-recreate "$app_service"
  fi

  after_all="$(all_app_containers)"
  new_container_id="$(find_new_container "$before_all" "$after_all")"
  echo "Waiting for new app container $new_container_id to become healthy..."
  wait_until_healthy "$new_container_id"

  if [[ -n "$old_container_id" ]]; then
    echo "Stopping previous app container $old_container_id..."
    previous_container_stopped=true
    docker container stop --time "$stop_timeout" "$old_container_id"
    docker container rm "$old_container_id"
    previous_container_stopped=false
  fi

  promotion_complete=true
  write_state "$target_tag" "$current"
  restore_scheduler

  echo "Release $target_tag is healthy and active."
  if [[ -n "$current" ]]; then
    echo "Previous release: $current"
  fi
  docker compose ps
}

list_releases() {
  local current
  local previous
  local tag
  local created
  local image_id
  local state
  local containers
  local container

  current="$(state_value current)"
  previous="$(state_value previous)"

  printf '%-42s %-25s %-16s %s\n' "TAG" "CREATED" "STATE" "CONTAINERS"
  while IFS=$'\t' read -r tag created image_id; do
    [[ -n "$tag" && "$tag" != "<none>" ]] || continue
    state=""
    [[ "$tag" == "$current" ]] && state="current"
    if [[ "$tag" == "$previous" ]]; then
      [[ -n "$state" ]] && state="$state,"
      state="${state}previous"
    fi

    containers=""
    while IFS= read -r container; do
      [[ -n "$container" ]] || continue
      [[ -z "$containers" ]] || containers="$containers,"
      containers="$containers$container"
    done < <(docker ps --all --filter "ancestor=$image_id" --format '{{.Names}}')

    printf '%-42s %-25s %-16s %s\n' "$tag" "$created" "${state:--}" "${containers:--}"
  done < <(docker image ls "$image_repository" --format '{{.Tag}}\t{{.CreatedAt}}\t{{.ID}}' | sort -r)
}

validate_positive_integer DEPLOY_HEALTH_TIMEOUT "$health_timeout"
validate_positive_integer DEPLOY_STOP_TIMEOUT "$stop_timeout"
mkdir -p "$state_dir"

command="${1:-}"
case "$command" in
  releases)
    [[ $# -eq 1 ]] || die "releases does not accept arguments"
    list_releases
    exit 0
    ;;
  deploy|rollback)
    ;;
  -h|--help|help|"")
    usage
    exit 0
    ;;
  *)
    usage >&2
    die "unknown command: $command"
    ;;
esac

exec 9>"$lock_file"
command -v flock >/dev/null 2>&1 || die "flock is required for deploy locking"
flock --nonblock 9 || die "another deploy or rollback is already running"
trap cleanup EXIT

case "$command" in
  deploy)
    [[ $# -eq 2 ]] || die "deploy requires exactly one RELEASE_TAG"
    perform_rollout "$2" false
    ;;
  rollback)
    [[ $# -le 2 ]] || die "rollback accepts at most one RELEASE_TAG"
    target_tag="${2:-$(state_value previous)}"
    [[ -n "$target_tag" ]] || die "there is no previous release recorded"
    perform_rollout "$target_tag" true
    ;;
esac
