source "https://rubygems.org"

# Rails
gem "rails", "~> 8.0"

# Drivers
gem "pg", "~> 1.5"
gem "redis", ">= 4.0.1"

# Deployment
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# Assets
gem "importmap-rails"
gem "propshaft"
gem "tailwindcss-rails"
gem "lucide-rails", github: "maybe-finance/lucide-rails"

# Background Jobs
gem "sidekiq"
gem "sidekiq-cron"

# Hotwire
gem "stimulus-rails"
gem "turbo-rails"
gem "hotwire_combobox", "~> 0.4.0"

# Other
gem "faraday"
gem "jbuilder"
gem "plaid", "~> 41.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "redcarpet"
gem "avo", ">= 3.2"
gem "revise_auth"
gem "pagy"
gem "ransack"
gem "bannerbear"
# gem "vernier"
gem "sentry-ruby"
gem "sentry-rails"
gem "logtail-rails"
gem "skylight"
gem "ffi", ">= 1.17", force_ruby_platform: true
gem "ruby-openai"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails"
  gem "erb_lint", require: false
end

group :development do
  gem "web-console"
  gem "hotwire-livereload"
  gem "ruby-lsp-rails"
  gem "annotate"
  gem "rails_performance"
  gem "rack-mini-profiler"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "mocha"
  gem "vcr"
  gem "webmock"
end
