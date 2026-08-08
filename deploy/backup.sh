#!/usr/bin/env bash

set -euo pipefail

SYNC="aws s3 sync"
SYNC_OPT="--no-progress"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VdP] $*"
}

usage() {
  echo "Usage: $(basename "$0") TARGET_DIR" >&2
}

if [[ $# -lt 1 || -z "${1:-}" ]]; then
  usage
  exit 1
fi

# Se recibe TARGET_DIR para mantener el contrato común de los backups,
# aunque este proyecto sincroniza uploads directamente a S3.
target_dir="$1"

on_error() {
  status=$?
  log "ERROR: uploads S3 sync failed (exit code: $status)"
  exit "$status"
}
trap on_error ERR

log "Starting uploads S3 sync"
for dir in /var/www/venganzasdelpasado.com.ar/202?; do
  [ -d "$dir" ] || continue
  year=$(basename "$dir")
  $SYNC "$dir/" "s3://s3.schwindt.org/dolina/$year/" --acl public-read $SYNC_OPT
done
