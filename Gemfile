source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'country_select', '~> 4.0'
gem 'dotenv-rails'
gem 'figaro'
gem 'hashid-rails', '~> 1.0'
gem 'jbuilder', '~> 2.7'
gem 'pg', '~> 1.3'
gem 'postmark-rails'
gem 'rails', '6.1.7.6'
gem 'rails_admin', '~> 2.2'
gem 'redcarpet'
gem 'sass-rails', '>= 6'
gem 'sprockets', '3.7.2'
gem 'webpacker', '~> 5.0'
gem 'rack-rewrite'
gem 'canonical-rails', github: 'jumph4x/canonical-rails'
gem 'reverse_markdown'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Webserver
gem 'puma', '~> 5.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.9.3', require: false

# Sync for Google Data Studio
gem 'activerecord-import'
gem 'convertkit-ruby'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  # gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
