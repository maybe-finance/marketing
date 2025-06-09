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

        if ENV["LOGTAIL_API_KEY"].present? && ENV["LOGTAIL_INGESTING_HOST"].present?
      begin
        puts "🌲 Configuring Logtail..."
        puts "   API Key: #{ENV['LOGTAIL_API_KEY'] ? 'Present' : 'Missing'}"
        puts "   Ingesting Host: #{ENV['LOGTAIL_INGESTING_HOST']}"

        config.logger = Logtail::Logger.create_default_logger(
          ENV["LOGTAIL_API_KEY"],
          ingesting_host: ENV["LOGTAIL_INGESTING_HOST"]
        )

        puts "✅ Logtail logger configured successfully"
      rescue => e
        puts "❌ Failed to configure Logtail: #{e.message}"
        puts "   Backtrace: #{e.backtrace.first(3).join(', ')}"
        puts "   Using standard Rails logger instead"
        # Fall back to standard Rails logger
        config.logger = ActiveSupport::Logger.new(STDOUT)
      end
        else
      missing_vars = []
      missing_vars << "LOGTAIL_API_KEY" unless ENV["LOGTAIL_API_KEY"].present?
      missing_vars << "LOGTAIL_INGESTING_HOST" unless ENV["LOGTAIL_INGESTING_HOST"].present?
      puts "⚠️  Logtail not configured. Missing environment variables: #{missing_vars.join(', ')}"
        end
  end
end
