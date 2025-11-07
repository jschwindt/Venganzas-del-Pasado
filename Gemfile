source "https://rubygems.org"

# Use main development branch of Rails
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
# gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem "bcrypt_pbkdf", ">= 1.0", "< 2.0"
gem "ed25519", ">= 1.2", "< 2.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "capistrano", "~> 3.19.2", require: false
  gem "capistrano-passenger", require: false
  gem "capistrano-rails", "~> 1.7.0", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "letter_opener"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  # gem "webdrivers"
end

gem "cancancan", "~> 3.6"

gem "aasm", "~> 5.5"

# gem "devise", "~> 4.9"
gem "devise", github: "heartcombo/devise", branch: "main"
gem "friendly_id", "~> 5.5"
gem "has_scope", "~> 0.8.2"
gem "hiredis", "~> 0.6.3"
gem "inherited_resources", "~> 2.1"
gem "kaminari", "~> 1.2"
gem "meilisearch-rails", "~> 0.16.0"
gem "recaptcha", "~> 5.21"
gem "redcarpet", "~> 3.6"
gem "redis", "~> 5.4"
gem "sitemap_generator", "~> 6.3"
gem "httpx", "~> 1.6"
gem "carrierwave", "~> 3.0"
gem "watu_table_builder", require: "table_builder"
gem "marksmith", github: "jschwindt/marksmith", branch: "main"

gem "dartsass-rails", "~> 0.5.1"

gem "bulma-rails", "~> 1.0"

gem "rails_icons", "~> 1.4"
