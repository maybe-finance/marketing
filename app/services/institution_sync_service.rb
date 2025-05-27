class InstitutionSyncService
  # Import country definitions from PlaidConfig
  EU_COUNTRIES = PlaidConfig::EU_COUNTRIES
  NON_EU_COUNTRIES = PlaidConfig::NON_EU_COUNTRIES
  ALL_SUPPORTED_COUNTRIES = PlaidConfig::ALL_SUPPORTED_COUNTRIES

  class << self
    # Sync all institutions from Plaid to our database with multi-region support
    def sync_all_institutions(country_codes: ALL_SUPPORTED_COUNTRIES, products: nil)
      Rails.logger.info "🔄 Starting multi-region institution sync for countries: #{country_codes}"

      start_time = Time.current

      # Check which regions we're dealing with
      region = PlaidConfig.region_for_countries(country_codes)

      case region
      when :mixed
        # Handle mixed regions by syncing each region separately
        sync_mixed_regions(country_codes: country_codes, products: products)
      else
        # Single region sync
        sync_single_region(country_codes: country_codes, products: products)
      end
    end

    # Sync institutions for a specific region
    def sync_by_region(region, products: nil)
      Rails.logger.info "🌍 Starting region-specific sync for: #{region}"

      country_codes = case region.to_sym
      when :eu
                       EU_COUNTRIES
      when :non_eu
                       NON_EU_COUNTRIES
      else
                       raise ArgumentError, "Invalid region: #{region}. Must be :eu or :non_eu"
      end

      # Check if credentials are configured for this region
      configured = case region.to_sym
      when :eu
                    PlaidConfig.eu_configured?
      when :non_eu
                    PlaidConfig.non_eu_configured?
      end

      unless configured
        error_msg = "#{region.to_s.upcase} credentials not configured - skipping #{region} sync"
        Rails.logger.warn "⚠️  #{error_msg}"
        return {
          created: 0,
          updated: 0,
          total_processed: 0,
          errors: [ error_msg ],
          region: region,
          skipped: true
        }
      end

      sync_single_region(country_codes: country_codes, products: products, region: region)
    end

    # Sync institutions for specific countries
    def sync_countries(country_codes, products: nil)
      Rails.logger.info "🏦 Starting country-specific sync for: #{country_codes}"
      sync_all_institutions(country_codes: country_codes, products: products)
    end

    # Sync institutions for a single country
    def sync_country(country_code, products: nil)
      sync_countries([ country_code ], products: products)
    end

    # Test sync with a small batch - now supports multi-region
    def test_sync(count: 5, country_codes: %w[US], products: nil)
      Rails.logger.info "🧪 Testing institution sync with #{count} institutions for countries: #{country_codes}"

      begin
        result = PlaidService.fetch_institutions(count: count, country_codes: country_codes, products: products)
        sync_result = sync_institutions(result[:institutions])

        {
          plaid_fetch: {
            total_available: result[:total],
            fetched: result[:institutions].length,
            countries: country_codes,
            region: PlaidConfig.region_for_countries(country_codes)
          },
          sync_result: sync_result,
          sample_institutions: Institution.where("country_codes && ARRAY[?]::varchar[]", country_codes).limit(3).pluck(:institution_id, :name)
        }
      rescue => e
        Rails.logger.error "Test sync failed for countries #{country_codes}: #{e.message}"
        {
          plaid_fetch: { error: e.message },
          sync_result: { created: 0, updated: 0, errors: [ e.message ] },
          sample_institutions: []
        }
      end
    end

    # Get sync statistics with region breakdown
    def sync_stats
      base_stats = {
        total_institutions: Institution.count,
        by_country: Institution.group("unnest(country_codes)").count,
        last_sync: Institution.maximum(:updated_at)
      }

      # Add region breakdown
      eu_count = Institution.where("country_codes && ARRAY[?]::varchar[]", EU_COUNTRIES).count
      non_eu_count = Institution.where("country_codes && ARRAY[?]::varchar[]", NON_EU_COUNTRIES).count

      base_stats.merge(
        by_region: {
          eu: eu_count,
          non_eu: non_eu_count
        },
        configuration: {
          eu_configured: PlaidConfig.eu_configured?,
          non_eu_configured: PlaidConfig.non_eu_configured?
        }
      )
    end

    private

    # Sync institutions for a single region
    def sync_single_region(country_codes:, products:, region: nil)
      region ||= PlaidConfig.region_for_countries(country_codes)

      Rails.logger.info "🔄 Syncing #{region} region for countries: #{country_codes}"

      start_time = Time.current

      begin
        plaid_institutions = PlaidService.fetch_all_institutions(
          country_codes: country_codes,
          products: products
        )

        result = sync_institutions(plaid_institutions)
        duration = Time.current - start_time

        Rails.logger.info "⏱️  #{region.to_s.upcase} region sync time: #{duration.round(2)} seconds"

        result.merge(
          region: region,
          duration: duration.round(2)
        )
      rescue PlaidService::AuthenticationError => e
        error_msg = "Authentication failed for #{region} region: #{e.message}"
        Rails.logger.error "❌ #{error_msg}"
        {
          created: 0,
          updated: 0,
          total_processed: 0,
          errors: [ error_msg ],
          region: region,
          failed: true
        }
      rescue PlaidService::RateLimitError => e
        error_msg = "Rate limit exceeded for #{region} region: #{e.message}"
        Rails.logger.error "❌ #{error_msg}"
        {
          created: 0,
          updated: 0,
          total_processed: 0,
          errors: [ error_msg ],
          region: region,
          rate_limited: true
        }
      rescue => e
        error_msg = "Unexpected error syncing #{region} region: #{e.message}"
        Rails.logger.error "❌ #{error_msg}"
        {
          created: 0,
          updated: 0,
          total_processed: 0,
          errors: [ error_msg ],
          region: region,
          failed: true
        }
      end
    end

    # Sync institutions for mixed regions
    def sync_mixed_regions(country_codes:, products:)
      Rails.logger.info "🌍 Starting mixed-region sync for countries: #{country_codes}"

      eu_countries = country_codes & EU_COUNTRIES
      non_eu_countries = country_codes & NON_EU_COUNTRIES

      results = {
        created: 0,
        updated: 0,
        total_processed: 0,
        errors: [],
        regions: {}
      }

      start_time = Time.current

      # Sync EU countries if present and configured
      if eu_countries.any?
        if PlaidConfig.eu_configured?
          Rails.logger.info "🇪🇺 Syncing EU countries: #{eu_countries}"
          eu_result = sync_single_region(
            country_codes: eu_countries,
            products: products,
            region: :eu
          )

          results[:created] += eu_result[:created]
          results[:updated] += eu_result[:updated]
          results[:total_processed] += eu_result[:total_processed]
          results[:errors].concat(eu_result[:errors])
          results[:regions][:eu] = eu_result
        else
          error_msg = "EU countries requested but EU credentials not configured: #{eu_countries}"
          Rails.logger.warn "⚠️  #{error_msg}"
          results[:errors] << error_msg
          results[:regions][:eu] = { skipped: true, reason: "credentials_not_configured" }
        end
      end

      # Sync non-EU countries if present and configured
      if non_eu_countries.any?
        if PlaidConfig.non_eu_configured?
          Rails.logger.info "🌎 Syncing non-EU countries: #{non_eu_countries}"
          non_eu_result = sync_single_region(
            country_codes: non_eu_countries,
            products: products,
            region: :non_eu
          )

          results[:created] += non_eu_result[:created]
          results[:updated] += non_eu_result[:updated]
          results[:total_processed] += non_eu_result[:total_processed]
          results[:errors].concat(non_eu_result[:errors])
          results[:regions][:non_eu] = non_eu_result
        else
          error_msg = "Non-EU countries requested but non-EU credentials not configured: #{non_eu_countries}"
          Rails.logger.warn "⚠️  #{error_msg}"
          results[:errors] << error_msg
          results[:regions][:non_eu] = { skipped: true, reason: "credentials_not_configured" }
        end
      end

      duration = Time.current - start_time
      Rails.logger.info "⏱️  Mixed-region sync total time: #{duration.round(2)} seconds"

      results.merge(
        duration: duration.round(2),
        mixed_region: true
      )
    end

    # Sync a batch of institutions
    def sync_institutions(plaid_institutions)
      return { created: 0, updated: 0, errors: [] } if plaid_institutions.empty?

      Rails.logger.info "💾 Syncing #{plaid_institutions.length} institutions to database"

      created_count = 0
      updated_count = 0
      errors = []

      plaid_institutions.each_with_index do |plaid_institution, index|
        begin
          institution_data = convert_plaid_institution(plaid_institution)
          institution = Institution.find_or_initialize_by(institution_id: institution_data[:institution_id])

          if institution.persisted?
            institution.update!(institution_data)
            updated_count += 1
          else
            institution.assign_attributes(institution_data)
            institution.save!
            created_count += 1
          end

          # Log progress every 100 institutions
          if (index + 1) % 100 == 0
            Rails.logger.info "📊 Progress: #{index + 1}/#{plaid_institutions.length} institutions processed"
          end

        rescue => e
          error_msg = "Failed to sync institution #{plaid_institution.institution_id}: #{e.message}"
          Rails.logger.error error_msg
          errors << error_msg
        end
      end

      result = {
        created: created_count,
        updated: updated_count,
        total_processed: plaid_institutions.length,
        errors: errors
      }

      Rails.logger.info "✅ Sync completed: #{created_count} created, #{updated_count} updated, #{errors.length} errors"
      result
    end

    # Convert Plaid institution format to our Institution model format
    def convert_plaid_institution(plaid_institution)
      # Enable detailed debugging when PLAID_DEBUG=true
      debug_plaid_institution(plaid_institution) if ENV["PLAID_DEBUG"] == "true"

      {
        institution_id: plaid_institution.institution_id,
        name: plaid_institution.name&.strip,
        country_codes: plaid_institution.country_codes || [],
        products: plaid_institution.products || [],
        logo_url: extract_logo_url(plaid_institution),
        website: extract_website_url(plaid_institution),
        oauth: extract_oauth_support(plaid_institution),
        primary_color: extract_primary_color(plaid_institution)
      }
    end



    # Extract logo URL from Plaid institution
    def extract_logo_url(plaid_institution)
      # First, try to use logo URL if Plaid actually provides it
      logo_url = plaid_institution.logo if plaid_institution.respond_to?(:logo)

      # If Plaid provides base64 image data, format it as a data URL
      if logo_url.present? && logo_url.match?(/^[A-Za-z0-9+\/=]+$/)
        logo_url = format_base64_image(logo_url)
      elsif logo_url.blank?
        # If no logo from Plaid, but we have a website URL, use Synth's logo service
        website_url = plaid_institution.url if plaid_institution.respond_to?(:url)
        if website_url.present?
          logo_url = generate_synth_logo_url(website_url)
        end
      end

      logo_url.present? ? logo_url : nil
    end

    # Extract website URL from Plaid institution
    def extract_website_url(plaid_institution)
      # Only use website URL if Plaid actually provides it
      website_url = plaid_institution.url if plaid_institution.respond_to?(:url)

      # Return nil if no URL from Plaid - no fallbacks for now
      website_url.present? ? website_url : nil
    end

    # Extract OAuth support information from Plaid institution
    def extract_oauth_support(plaid_institution)
      # OAuth support is actually provided by Plaid
      oauth_supported = plaid_institution.oauth if plaid_institution.respond_to?(:oauth)

      # Return boolean value, defaulting to false if not specified
      oauth_supported == true
    end

    # Extract primary color from Plaid institution
    def extract_primary_color(plaid_institution)
      # Primary color is provided by Plaid when include_optional_metadata is true
      primary_color = plaid_institution.primary_color if plaid_institution.respond_to?(:primary_color)

      # Return the color if available, nil otherwise
      primary_color.present? ? primary_color : nil
    end

    # Generate Synth logo URL from website URL
    def generate_synth_logo_url(website_url)
      # Extract domain from URL for Synth's logo service
      # Remove protocol and www prefix, keep just the domain
      domain = website_url.gsub(/^https?:\/\//, "").gsub(/^www\./, "").split("/").first

      # Return Synth logo service URL
      "https://logo.synthfinance.com/#{domain}"
    end

    # Format base64 image data as a proper data URL
    def format_base64_image(base64_data)
      # Plaid typically provides PNG images
      # Format as data URL for use in HTML img tags
      "data:image/png;base64,#{base64_data}"
    end



    # Debug method to inspect what Plaid is actually returning
    # Only runs when PLAID_DEBUG=true environment variable is set
    # Usage: PLAID_DEBUG=true rails institutions:test_sync
    def debug_plaid_institution(plaid_institution)
      return unless ENV["PLAID_DEBUG"] == "true"

      Rails.logger.debug "🔍 DEBUG: Plaid Institution Analysis for '#{plaid_institution.name}'"
      Rails.logger.debug "   Institution ID: #{plaid_institution.institution_id}"
      Rails.logger.debug "   Class: #{plaid_institution.class.name}"

      # Check all available methods
      available_methods = plaid_institution.methods.reject { |m|
        m.to_s.start_with?("_") || Object.methods.include?(m)
      }.sort

      Rails.logger.debug "   Available methods: #{available_methods.join(', ')}"

      # Check specific fields we're interested in
      fields_to_check = [ :logo, :url, :status, :primary_color, :oauth, :auth_metadata,
                        :payment_initiation_metadata, :routing_numbers, :dtc_numbers ]

      fields_to_check.each do |field|
        if plaid_institution.respond_to?(field)
          value = plaid_institution.send(field)
          Rails.logger.debug "   #{field}: #{value.inspect} (#{value.class.name})"

          # If it's a complex object, try to inspect its structure
          if value && !value.is_a?(String) && !value.is_a?(Numeric) && !value.is_a?(TrueClass) && !value.is_a?(FalseClass) && !value.nil?
            if value.respond_to?(:methods)
              sub_methods = value.methods.reject { |m|
                m.to_s.start_with?("_") || Object.methods.include?(m)
              }.sort
              Rails.logger.debug "     └─ #{field} methods: #{sub_methods.join(', ')}"
            end

            if value.respond_to?(:to_h)
              begin
                Rails.logger.debug "     └─ #{field} as hash: #{value.to_h.inspect}"
              rescue => e
                Rails.logger.debug "     └─ #{field} to_h failed: #{e.message}"
              end
            end
          end
        else
          Rails.logger.debug "   #{field}: [method not available]"
        end
      end

      Rails.logger.debug "🔍 END DEBUG for '#{plaid_institution.name}'"
      Rails.logger.debug ""
    end

    def logger
      Rails.logger
    end
  end
end
