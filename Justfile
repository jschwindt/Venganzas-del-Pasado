set dotenv-load := true

@_:
    just --list

[doc('Upgrade gems')]
[group('local-dev')]
upgrade-gems:
    bundle update

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

deploy:
    bundle exec cap production deploy