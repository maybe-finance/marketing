class InstitutionSyncJob < ApplicationJob
  queue_as :default

  # Configure retry behavior
  # retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(country_codes = [ "US", "GB", "ES", "NL", "FR", "IE", "CA", "DE", "IT", "PL", "DK", "NO", "SE", "EE", "LT", "LV", "PT", "BE", "AT", "FI" ], products = nil)
    Rails.logger.info "🚀 Starting scheduled institution sync job"
    start_time = Time.current

    begin
      # Use our existing InstitutionSyncService for the heavy lifting
      result = InstitutionSyncService.sync_all_institutions(
        country_codes: country_codes,
        products: products
      )

      duration = Time.current - start_time

      # Log successful completion
      Rails.logger.info "✅ Institution sync job completed successfully in #{duration.round(2)}s"
      Rails.logger.info "📊 Results: #{result[:created]} created, #{result[:updated]} updated, #{result[:errors].length} errors"

      # Log errors if any occurred
      if result[:errors].any?
        Rails.logger.warn "⚠️  Sync completed with #{result[:errors].length} errors:"
        result[:errors].first(5).each { |error| Rails.logger.warn "   - #{error}" }
      end

      # Return result for potential monitoring/alerting
      result

    rescue => e
      duration = Time.current - start_time
      Rails.logger.error "❌ Institution sync job failed after #{duration.round(2)}s: #{e.message}"
      Rails.logger.error "   Error class: #{e.class}"
      Rails.logger.error "   Backtrace: #{e.backtrace.first(5).join("\n   ")}"

      # Re-raise to trigger retry mechanism
      raise e
    end
  end

  # Class method to enqueue the job
  def self.sync_now(country_codes = [ "US", "GB", "ES", "NL", "FR", "IE", "CA", "DE", "IT", "PL", "DK", "NO", "SE", "EE", "LT", "LV", "PT", "BE", "AT", "FI" ], products = nil)
    perform_later(country_codes, products)
  end

  # Class method to get job statistics (for Sidekiq backend)
  def self.job_stats
    require "sidekiq/api"

    {
      enqueued: Sidekiq::Queue.new("default").select { |job| job.klass == "InstitutionSyncJob" }.size,
      processing: Sidekiq::Workers.new.select { |process_id, thread_id, work| work["payload"]["class"] == "InstitutionSyncJob" }.size,
      failed: Sidekiq::DeadSet.new.select { |job| job.klass == "InstitutionSyncJob" }.size
    }
  end
end
