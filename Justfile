set dotenv-load := true

@_:
    just --list

[doc('Upgrade gems')]
[group('local-dev')]
upgrade-gems:
    ./bin/bundler-audit check --update

[group('local-dev')]
dev:
    bin/dev

[group('local-dev')]
test:
    bin/rails test
    bin/rails test:system

[group('local-dev')]
audit:
    bundle-audit update
    bundle-audit check
