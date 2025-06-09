require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MaybeMarketing
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_support.to_time_preserves_timezone = :zone

    # Configure Logtail only if API key is present, but delay initialization until after fork
    if ENV["LOGTAIL_API_KEY"].present? && ENV["LOGTAIL_INGESTING_HOST"].present?
      puts "🌲 Logtail environment variables detected - will configure after worker fork"
      # Use standard Rails logger initially, will switch to Logtail after fork
      config.logger = ActiveSupport::Logger.new(STDOUT)
    else
      missing_vars = []
      missing_vars << "LOGTAIL_API_KEY" unless ENV["LOGTAIL_API_KEY"].present?
      missing_vars << "LOGTAIL_INGESTING_HOST" unless ENV["LOGTAIL_INGESTING_HOST"].present?
      puts "⚠️  Logtail not configured. Missing environment variables: #{missing_vars.join(', ')}"
    end
  end
end
