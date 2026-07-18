# syntax=docker/dockerfile:1
# check=error=true

# Production image for the Rails app only. Caddy handles TLS and host-mounted
# media while Rails serves its digest-stamped assets.

ARG RUBY_VERSION=4.0.6
ARG BUN_VERSION=1.2.23

FROM docker.io/oven/bun:${BUN_VERSION}-slim AS bun

FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client git imagemagick libjemalloc2 tzdata && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    RACK_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so" \
    MALLOC_ARENA_MAX="2" \
    PORT="3000" \
    WEB_CONCURRENCY="2" \
    RAILS_MAX_THREADS="3"

FROM base AS build

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

COPY Rakefile config.ru ./
COPY app ./app
COPY bin ./bin
COPY config ./config
COPY db ./db
COPY lib ./lib
COPY public ./public

RUN bundle exec bootsnap precompile -j 1 app/ lib/
RUN DATABASE_URL="mysql2://root@127.0.0.1/vdp_build" \
    REDIS_URL="redis://127.0.0.1:6379/0" \
    MEILISEARCH_API_KEY="build-only-placeholder" \
    RECAPTCHA_SITE_KEY="build-only-placeholder" \
    RECAPTCHA_SECRET_KEY="build-only-placeholder" \
    SECRET_KEY_BASE_DUMMY=1 \
    ./bin/rails assets:precompile
RUN rm -rf node_modules tmp/cache package.json bun.lockb

FROM base

WORKDIR /rails

RUN groupadd --system --gid 1001 rails && \
    useradd rails --uid 1001 --gid 1001 --create-home --shell /bin/bash --no-log-init

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

RUN mkdir -p log tmp/pids tmp/cache storage public/uploads && \
    chown -R rails:rails log tmp storage public/uploads && \
    ln -sf /dev/stdout log/production.log

USER 1001:1001

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD curl -fsS "http://127.0.0.1:${PORT:-3000}/up" || exit 1

CMD ["./bin/rails", "server"]
