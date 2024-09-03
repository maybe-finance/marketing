source "https://rubygems.org"

# Rails
gem "rails", github: "rails/rails", branch: "main"

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

# Hotwire
gem "stimulus-rails"
gem "turbo-rails"

# Other
gem "faraday"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "redcarpet"
gem "avo", ">= 3.2"
gem "revise_auth"
gem "pagy"
gem "bannerbear"
gem "sentry-ruby"
gem "sentry-rails"

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
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
