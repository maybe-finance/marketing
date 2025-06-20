# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# to prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Specifies the `environment` that Puma will run in.
rails_env = ENV.fetch("RAILS_ENV", "development")
environment rails_env

case rails_env
when "production"
  # If you are running more than 1 thread per process, the workers count
  # should be equal to the number of processors (CPU cores) in production.
  #
  # It defaults to 1 because it's impossible to reliably detect how many
  # CPU cores are available. Make sure to set the `WEB_CONCURRENCY` environment
  # variable to match the number of processors.
  workers_count = Integer(ENV.fetch("WEB_CONCURRENCY", 1))
  workers workers_count if workers_count > 1

  preload_app!
when "development"
  # Specifies a very generous `worker_timeout` so that the worker
  # isn't killed by Puma when suspended by a debugger.
  worker_timeout 3600
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Only use a pidfile when requested
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Configure Logtail after worker fork to prevent thread inheritance issues
if ENV["LOGTAIL_API_KEY"] && !ENV["LOGTAIL_API_KEY"].empty? && ENV["LOGTAIL_INGESTING_HOST"] && !ENV["LOGTAIL_INGESTING_HOST"].empty?
  on_worker_boot do
    puts "🔧 Worker #{Process.pid}: Initializing Logtail after fork"

    begin
      # Initialize Logtail in each worker process
      logtail_logger = Logtail::Logger.create_default_logger(
        ENV["LOGTAIL_API_KEY"],
        ingesting_host: ENV["LOGTAIL_INGESTING_HOST"]
      )

      # Replace Rails logger with Logtail logger
      Rails.logger = logtail_logger

      puts "✅ Worker #{Process.pid}: Logtail configured successfully"
    rescue => e
      puts "❌ Worker #{Process.pid}: Failed to configure Logtail: #{e.message}"
      puts "   Keeping standard Rails logger"
    end
  end

  # Clean up Logtail connections when worker shuts down
  on_worker_shutdown do
    puts "🧹 Worker #{Process.pid}: Shutting down Logtail"
    Rails.logger.close if Rails.logger.respond_to?(:close)
  end
end
