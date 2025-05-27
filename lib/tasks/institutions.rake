namespace :institutions do
  desc "Sync institutions from Plaid API (supports multi-region)"
  task sync: :environment do
    puts "🏦 Starting multi-region institution sync from Plaid..."

    begin
      # Test connections for all configured regions first
      connection_tests = PlaidService.test_all_connections

      puts "\n🔌 Testing Plaid connections:"
      connection_tests.each do |region, result|
        if result[:success]
          puts "✅ #{region.to_s.upcase} region: Connected (#{result[:environment]} environment, #{result[:total_institutions]} institutions available)"
        else
          puts "❌ #{region.to_s.upcase} region: #{result[:message]}"
        end
      end

      # Check if at least one region is configured
      configured_regions = connection_tests.select { |_, result| result[:success] }
      if configured_regions.empty?
        puts "\n❌ No Plaid regions are properly configured. Please check your environment variables."
        exit 1
      end

      puts "\n🔄 Proceeding with sync for configured regions..."

      # Perform sync for all supported countries
      result = InstitutionSyncService.sync_all_institutions

      puts "\n📊 Sync Results:"
      if result[:mixed_region]
        puts "   Mixed-region sync completed"
        puts "   Total created: #{result[:created]}"
        puts "   Total updated: #{result[:updated]}"
        puts "   Total processed: #{result[:total_processed]}"
        puts "   Total errors: #{result[:errors].length}"
        puts "   Duration: #{result[:duration]} seconds"

        puts "\n📋 By Region:"
        result[:regions].each do |region, region_result|
          if region_result[:skipped]
            puts "   #{region.to_s.upcase}: Skipped (#{region_result[:reason]})"
          else
            puts "   #{region.to_s.upcase}: #{region_result[:created]} created, #{region_result[:updated]} updated"
          end
        end
      else
        puts "   Single-region sync completed"
        puts "   Region: #{result[:region]}"
        puts "   Created: #{result[:created]}"
        puts "   Updated: #{result[:updated]}"
        puts "   Total processed: #{result[:total_processed]}"
        puts "   Errors: #{result[:errors].length}"
        puts "   Duration: #{result[:duration]} seconds"
      end

      if result[:errors].any?
        puts "\n❌ Errors encountered:"
        result[:errors].first(5).each { |error| puts "   - #{error}" }
        puts "   ... and #{result[:errors].length - 5} more" if result[:errors].length > 5
      end

      # Show final stats
      stats = InstitutionSyncService.sync_stats
      puts "\n📈 Final Statistics:"
      puts "   Total institutions in database: #{stats[:total_institutions]}"
      puts "   By region: EU=#{stats[:by_region][:eu]}, Non-EU=#{stats[:by_region][:non_eu]}"
      puts "   By country: #{stats[:by_country]}"
      puts "   Configuration: EU=#{stats[:configuration][:eu_configured] ? 'configured' : 'not configured'}, Non-EU=#{stats[:configuration][:non_eu_configured] ? 'configured' : 'not configured'}"

      puts "\n🎉 Institution sync completed successfully!"

    rescue => e
      puts "❌ Institution sync failed: #{e.message}"
      puts "   Error class: #{e.class}"
      exit 1
    end
  end

  desc "Sync institutions for a specific region (eu or non_eu)"
  task :sync_region, [ :region ] => :environment do |t, args|
    region = args[:region]

    unless %w[eu non_eu].include?(region)
      puts "❌ Invalid region: #{region}. Must be 'eu' or 'non_eu'"
      exit 1
    end

    puts "🌍 Starting #{region.upcase} region institution sync..."

    begin
      # Test connection for the specific region
      connection_test = PlaidService.test_connection(region.to_sym)

      if connection_test[:success]
        puts "✅ #{region.upcase} region connection successful (#{connection_test[:environment]} environment)"
        puts "📊 Total institutions available: #{connection_test[:total_institutions]}"
      else
        puts "❌ #{region.upcase} region connection failed: #{connection_test[:message]}"
        exit 1
      end

      # Perform region-specific sync
      result = InstitutionSyncService.sync_by_region(region)

      puts "\n📊 #{region.upcase} Region Sync Results:"
      if result[:skipped]
        puts "   Skipped: #{result[:errors].first}"
      elsif result[:failed] || result[:rate_limited]
        puts "   Failed: #{result[:errors].first}"
      else
        puts "   Created: #{result[:created]}"
        puts "   Updated: #{result[:updated]}"
        puts "   Total processed: #{result[:total_processed]}"
        puts "   Errors: #{result[:errors].length}"
        puts "   Duration: #{result[:duration]} seconds"
      end

      if result[:errors].any?
        puts "\n❌ Errors encountered:"
        result[:errors].each { |error| puts "   - #{error}" }
      end

      puts "\n🎉 #{region.upcase} region sync completed!"

    rescue => e
      puts "❌ #{region.upcase} region sync failed: #{e.message}"
      exit 1
    end
  end

  desc "Sync institutions for specific countries"
  task :sync_countries, [ :countries ] => :environment do |t, args|
    countries = args[:countries]&.split(",")&.map(&:strip)&.map(&:upcase)

    if countries.blank?
      puts "❌ No countries specified. Usage: rake institutions:sync_countries[US,CA,ES]"
      exit 1
    end

    # Validate countries
    invalid_countries = countries - PlaidConfig::ALL_SUPPORTED_COUNTRIES
    if invalid_countries.any?
      puts "❌ Invalid countries: #{invalid_countries.join(', ')}"
      puts "   Supported countries: #{PlaidConfig::ALL_SUPPORTED_COUNTRIES.join(', ')}"
      exit 1
    end

    puts "🏦 Starting institution sync for countries: #{countries.join(', ')}"

    begin
      # Determine which regions we need
      region = PlaidConfig.region_for_countries(countries)
      puts "📍 Region type: #{region}"

      # Perform country-specific sync
      result = InstitutionSyncService.sync_countries(countries)

      puts "\n📊 Country Sync Results:"
      if result[:mixed_region]
        puts "   Mixed-region sync for #{countries.join(', ')}"
        puts "   Total created: #{result[:created]}"
        puts "   Total updated: #{result[:updated]}"
        puts "   Total processed: #{result[:total_processed]}"
        puts "   Total errors: #{result[:errors].length}"
        puts "   Duration: #{result[:duration]} seconds"
      else
        puts "   Single-region sync for #{countries.join(', ')}"
        puts "   Region: #{result[:region]}"
        puts "   Created: #{result[:created]}"
        puts "   Updated: #{result[:updated]}"
        puts "   Total processed: #{result[:total_processed]}"
        puts "   Errors: #{result[:errors].length}"
        puts "   Duration: #{result[:duration]} seconds"
      end

      if result[:errors].any?
        puts "\n❌ Errors encountered:"
        result[:errors].each { |error| puts "   - #{error}" }
      end

      puts "\n🎉 Country sync completed!"

    rescue => e
      puts "❌ Country sync failed: #{e.message}"
      exit 1
    end
  end

  desc "Test sync with a small batch of institutions"
  task test_sync: :environment do
    puts "🧪 Testing institution sync with small batch..."

    begin
      # Test with a mix of regions if both are configured
      test_countries = []
      if PlaidConfig.non_eu_configured?
        test_countries << "US"
      end
      if PlaidConfig.eu_configured?
        test_countries << "ES"
      end

      if test_countries.empty?
        puts "❌ No Plaid credentials configured for testing"
        exit 1
      end

      result = InstitutionSyncService.test_sync(count: 10, country_codes: test_countries)

      puts "✅ Test sync completed!"
      puts "📊 Results:"
      if result[:plaid_fetch][:error]
        puts "   Fetch error: #{result[:plaid_fetch][:error]}"
      else
        puts "   Countries tested: #{result[:plaid_fetch][:countries].join(', ')}"
        puts "   Region: #{result[:plaid_fetch][:region]}"
        puts "   Total available: #{result[:plaid_fetch][:total_available]}"
        puts "   Fetched: #{result[:plaid_fetch][:fetched]}"
      end
      puts "   Created: #{result[:sync_result][:created]}"
      puts "   Updated: #{result[:sync_result][:updated]}"
      puts "   Errors: #{result[:sync_result][:errors].length}"

      puts "\n📋 Sample institutions:"
      result[:sample_institutions].each do |id, name|
        puts "   - #{id}: #{name}"
      end

    rescue => e
      puts "❌ Test sync failed: #{e.message}"
      exit 1
    end
  end

  desc "Show institution statistics with region breakdown"
  task stats: :environment do
    puts "📊 Institution Statistics:"

    stats = InstitutionSyncService.sync_stats
    puts "   Total institutions: #{stats[:total_institutions]}"
    puts "   Last sync: #{stats[:last_sync] || 'Never'}"

    puts "\n🌍 By Region:"
    puts "   EU: #{stats[:by_region][:eu]}"
    puts "   Non-EU: #{stats[:by_region][:non_eu]}"

    puts "\n🌍 By Country:"
    stats[:by_country].each { |country, count| puts "   #{country}: #{count}" }

    puts "\n⚙️  Configuration:"
    puts "   EU credentials: #{stats[:configuration][:eu_configured] ? '✅ Configured' : '❌ Not configured'}"
    puts "   Non-EU credentials: #{stats[:configuration][:non_eu_configured] ? '✅ Configured' : '❌ Not configured'}"

    # Show some sample institutions by region
    puts "\n📋 Sample EU Institutions:"
    Institution.where("country_codes && ARRAY[?]::varchar[]", PlaidConfig::EU_COUNTRIES).limit(3).each do |institution|
      puts "   - #{institution.institution_id}: #{institution.name} (#{institution.country_codes.join(', ')})"
    end

    puts "\n📋 Sample Non-EU Institutions:"
    Institution.where("country_codes && ARRAY[?]::varchar[]", PlaidConfig::NON_EU_COUNTRIES).limit(3).each do |institution|
      puts "   - #{institution.institution_id}: #{institution.name} (#{institution.country_codes.join(', ')})"
    end
  end

  desc "Test Plaid connections for all regions"
  task test_connection: :environment do
    puts "🔌 Testing Plaid connections for all regions..."

    results = PlaidService.test_all_connections

    results.each do |region, result|
      puts "\n#{region.to_s.upcase} Region:"
      if result[:success]
        puts "   ✅ Connection successful!"
        puts "   Environment: #{result[:environment]}"
        puts "   Total institutions available: #{result[:total_institutions]}"
      else
        puts "   ❌ Connection failed!"
        puts "   Error: #{result[:error]}" if result[:error]
        puts "   Message: #{result[:message]}"
        puts "   Environment: #{result[:environment]}" if result[:environment]
      end
    end

    # Summary
    successful_regions = results.select { |_, result| result[:success] }.keys
    puts "\n📊 Summary:"
    puts "   Configured regions: #{successful_regions.map(&:to_s).map(&:upcase).join(', ')}"
    puts "   Total configured regions: #{successful_regions.length}/2"

    if successful_regions.empty?
      puts "\n⚠️  No regions are properly configured. Please check your environment variables:"
      puts "   Non-EU: PLAID_CLIENT_ID, PLAID_SECRET"
      puts "   EU: PLAID_EU_CLIENT_ID, PLAID_EU_SECRET"
    end
  end

  desc "Queue institution sync job"
  task sync_async: :environment do
    puts "📋 Queueing institution sync job..."

    job = InstitutionSyncJob.perform_later
    puts "✅ Job queued: #{job.class.name}"
    puts "   Monitor progress in Sidekiq web UI or logs"

    # Show current job stats
    stats = InstitutionSyncJob.job_stats
    puts "\n📊 Current Job Stats:"
    puts "   Enqueued: #{stats[:enqueued]}"
    puts "   Processing: #{stats[:processing]}"
    puts "   Failed: #{stats[:failed]}"
  end

  desc "Show scheduled jobs status"
  task scheduled_jobs: :environment do
    puts "⏰ Scheduled Institution Sync Jobs:"

    require "sidekiq-cron"

    jobs = Sidekiq::Cron::Job.all
    institution_jobs = jobs.select { |job| job.klass == "InstitutionSyncJob" }

    if institution_jobs.any?
      institution_jobs.each do |job|
        puts "   📅 #{job.name}:"
        puts "      Schedule: #{job.cron}"
        puts "      Status: #{job.status}"
        puts "      Last run: #{job.last_enqueue_time || 'Never'}"
        puts ""
      end
    else
      puts "   No scheduled institution sync jobs found"
      puts "   Run 'rails restart' to load jobs from config/schedule.yml"
    end
  end

  desc "Test scheduled job setup"
  task test_scheduled_jobs: :environment do
    puts "🧪 Testing scheduled job setup..."

    require "sidekiq-cron"

    # Load jobs from schedule.yml
    schedule_file = Rails.root.join("config", "schedule.yml")
    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)
      puts "✅ Schedule file found with #{schedule.keys.length} jobs"

      schedule.each do |name, config|
        puts "   📅 #{name}: #{config['cron']} (#{config['class']})"
      end
    else
      puts "❌ Schedule file not found at #{schedule_file}"
    end

    # Check if jobs are loaded in Sidekiq-Cron
    jobs = Sidekiq::Cron::Job.all
    puts "\n📊 Sidekiq-Cron Status:"
    puts "   Total jobs loaded: #{jobs.length}"

    institution_jobs = jobs.select { |job| job.klass == "InstitutionSyncJob" }
    puts "   Institution sync jobs: #{institution_jobs.length}"

    if institution_jobs.any?
      puts "   ✅ Institution sync jobs are properly scheduled"
    else
      puts "   ⚠️  No institution sync jobs found in Sidekiq-Cron"
      puts "   Try running 'rails restart' to reload the schedule"
    end
  end
end
