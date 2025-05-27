class PlaidService
  # Error classes for better error handling
  class PlaidError < StandardError; end
  class RateLimitError < PlaidError; end
  class AuthenticationError < PlaidError; end
  class NetworkError < PlaidError; end

  # Import country definitions from PlaidConfig
  EU_COUNTRIES = PlaidConfig::EU_COUNTRIES
  NON_EU_COUNTRIES = PlaidConfig::NON_EU_COUNTRIES
  ALL_SUPPORTED_COUNTRIES = PlaidConfig::ALL_SUPPORTED_COUNTRIES

  class << self
    # Get the configured Plaid client for specific country codes
    # @param country_codes [Array<String>] Array of country codes
    # @return [Plaid::PlaidApi] Configured Plaid API client
    def client(country_codes = %w[US])
      PlaidConfig.client_for_countries(country_codes)
    end

    # Fetch institutions with pagination support and region-aware routing
    def fetch_institutions(count: 500, offset: 0, country_codes: ALL_SUPPORTED_COUNTRIES, products: nil)
      Rails.logger.info "🔍 Fetching institutions: count=#{count}, offset=#{offset}, countries=#{country_codes}"

      # Check if we have mixed regions
      region = PlaidConfig.region_for_countries(country_codes)

      case region
      when :mixed
        # Handle mixed regions by splitting the request
        fetch_institutions_mixed_regions(count: count, offset: offset, country_codes: country_codes, products: products)
      else
        # Single region request
        fetch_institutions_single_region(count: count, offset: offset, country_codes: country_codes, products: products)
      end
    end

    # Fetch all institutions with automatic pagination and region-aware routing
    def fetch_all_institutions(country_codes: ALL_SUPPORTED_COUNTRIES, products: nil, batch_size: 500)
      Rails.logger.info "🏦 Starting to fetch all institutions for countries: #{country_codes}"

      # Check if we have mixed regions
      region = PlaidConfig.region_for_countries(country_codes)

      case region
      when :mixed
        # Handle mixed regions by splitting the request
        fetch_all_institutions_mixed_regions(country_codes: country_codes, products: products, batch_size: batch_size)
      else
        # Single region request
        fetch_all_institutions_single_region(country_codes: country_codes, products: products, batch_size: batch_size)
      end
    end

    # Fetch institutions for a specific country
    def fetch_institutions_by_country(country_code, products: nil)
      fetch_all_institutions(country_codes: [ country_code ], products: products)
    end

    # Fetch institutions by region
    def fetch_institutions_by_region(region, products: nil)
      country_codes = case region.to_sym
      when :eu
                       EU_COUNTRIES
      when :non_eu
                       NON_EU_COUNTRIES
      else
                       raise ArgumentError, "Invalid region: #{region}. Must be :eu or :non_eu"
      end

      fetch_all_institutions(country_codes: country_codes, products: products)
    end

    # Test the Plaid connection for a specific region
    def test_connection(region = :non_eu)
      begin
        # Test with a single country from the region
        test_country = region == :eu ? EU_COUNTRIES.first : NON_EU_COUNTRIES.first
        result = fetch_institutions(count: 1, offset: 0, country_codes: [ test_country ])
        {
          success: true,
          message: "Successfully connected to Plaid API",
          region: region,
          environment: PlaidConfig.send(:environment),
          total_institutions: result[:total]
        }
      rescue => e
        {
          success: false,
          message: "Failed to connect to Plaid API: #{e.message}",
          region: region,
          environment: PlaidConfig.send(:environment),
          error: e.class.name
        }
      end
    end

    # Test connections for all configured regions
    def test_all_connections
      results = {}

      # Test non-EU if configured
      if PlaidConfig.non_eu_configured?
        results[:non_eu] = test_connection(:non_eu)
      else
        results[:non_eu] = {
          success: false,
          message: "Non-EU credentials not configured",
          region: :non_eu
        }
      end

      # Test EU if configured
      if PlaidConfig.eu_configured?
        results[:eu] = test_connection(:eu)
      else
        results[:eu] = {
          success: false,
          message: "EU credentials not configured",
          region: :eu
        }
      end

      results
    end

    private

    # Fetch institutions for a single region
    def fetch_institutions_single_region(count:, offset:, country_codes:, products:)
      request = build_institutions_request(count: count, offset: offset, country_codes: country_codes, products: products)

      with_error_handling(country_codes) do
        response = client(country_codes).institutions_get(request)
        {
          institutions: response.institutions,
          total: response.total,
          count: count,
          offset: offset,
          has_more: (offset + count) < response.total
        }
      end
    end

    # Fetch institutions for mixed regions by splitting the request
    def fetch_institutions_mixed_regions(count:, offset:, country_codes:, products:)
      Rails.logger.info "🌍 Handling mixed-region request for countries: #{country_codes}"

      eu_countries = country_codes & EU_COUNTRIES
      non_eu_countries = country_codes & NON_EU_COUNTRIES

      all_institutions = []
      total_count = 0

      # Fetch from EU region if we have EU countries
      if eu_countries.any? && PlaidConfig.eu_configured?
        Rails.logger.info "🇪🇺 Fetching EU institutions for: #{eu_countries}"
        eu_result = fetch_institutions_single_region(
          count: count,
          offset: offset,
          country_codes: eu_countries,
          products: products
        )
        all_institutions.concat(eu_result[:institutions])
        total_count += eu_result[:total]
      end

      # Fetch from non-EU region if we have non-EU countries
      if non_eu_countries.any? && PlaidConfig.non_eu_configured?
        Rails.logger.info "🌎 Fetching non-EU institutions for: #{non_eu_countries}"
        non_eu_result = fetch_institutions_single_region(
          count: count,
          offset: offset,
          country_codes: non_eu_countries,
          products: products
        )
        all_institutions.concat(non_eu_result[:institutions])
        total_count += non_eu_result[:total]
      end

      {
        institutions: all_institutions,
        total: total_count,
        count: all_institutions.length,
        offset: offset,
        has_more: false # Mixed region requests don't support pagination in the same way
      }
    end

    # Fetch all institutions for a single region with pagination
    def fetch_all_institutions_single_region(country_codes:, products:, batch_size:)
      all_institutions = []
      offset = 0
      total_fetched = 0

      loop do
        Rails.logger.info "📄 Fetching batch: offset=#{offset}, batch_size=#{batch_size}"

        result = fetch_institutions_single_region(
          count: batch_size,
          offset: offset,
          country_codes: country_codes,
          products: products
        )

        institutions = result[:institutions]
        all_institutions.concat(institutions)
        total_fetched += institutions.length

        Rails.logger.info "✅ Fetched #{institutions.length} institutions (total: #{total_fetched}/#{result[:total]})"

        # Break if we've fetched all institutions or if the batch was smaller than expected
        break unless result[:has_more] && institutions.length == batch_size

        offset += batch_size

        # Add a small delay to respect rate limits
        sleep(0.1)
      end

      Rails.logger.info "🎉 Completed fetching #{all_institutions.length} institutions"
      all_institutions
    end

    # Fetch all institutions for mixed regions
    def fetch_all_institutions_mixed_regions(country_codes:, products:, batch_size:)
      Rails.logger.info "🌍 Handling mixed-region fetch for countries: #{country_codes}"

      eu_countries = country_codes & EU_COUNTRIES
      non_eu_countries = country_codes & NON_EU_COUNTRIES

      all_institutions = []

      # Fetch from EU region if we have EU countries and credentials
      if eu_countries.any? && PlaidConfig.eu_configured?
        Rails.logger.info "🇪🇺 Fetching all EU institutions for: #{eu_countries}"
        eu_institutions = fetch_all_institutions_single_region(
          country_codes: eu_countries,
          products: products,
          batch_size: batch_size
        )
        all_institutions.concat(eu_institutions)
      elsif eu_countries.any?
        Rails.logger.warn "⚠️  EU countries requested but EU credentials not configured: #{eu_countries}"
      end

      # Fetch from non-EU region if we have non-EU countries and credentials
      if non_eu_countries.any? && PlaidConfig.non_eu_configured?
        Rails.logger.info "🌎 Fetching all non-EU institutions for: #{non_eu_countries}"
        non_eu_institutions = fetch_all_institutions_single_region(
          country_codes: non_eu_countries,
          products: products,
          batch_size: batch_size
        )
        all_institutions.concat(non_eu_institutions)
      elsif non_eu_countries.any?
        Rails.logger.warn "⚠️  Non-EU countries requested but non-EU credentials not configured: #{non_eu_countries}"
      end

      Rails.logger.info "🎉 Completed mixed-region fetch: #{all_institutions.length} total institutions"
      all_institutions
    end

    # Build the institutions request object
    def build_institutions_request(count:, offset:, country_codes:, products:)
      request_params = {
        count: count,
        offset: offset,
        country_codes: country_codes,
        options: {
          include_optional_metadata: true,  # Request logos, URLs, and primary colors
          include_auth_metadata: true,      # Request auth-related metadata
          include_payment_initiation_metadata: true  # Request payment metadata
        }
      }

      # Add products filter if specified
      if products.present?
        request_params[:options][:products] = products
      end

      Plaid::InstitutionsGetRequest.new(request_params)
    end

    # Handle Plaid API errors with proper classification and region context
    def with_error_handling(country_codes = [])
      yield
    rescue Plaid::ApiError => e
      handle_plaid_api_error(e, country_codes)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise NetworkError, "Network error: #{e.message}"
    rescue => e
      Rails.logger.error "Unexpected Plaid API error for countries #{country_codes}: #{e.class} - #{e.message}"
      raise PlaidError, "Unexpected error: #{e.message}"
    end

    # Handle specific Plaid API errors with region context
    def handle_plaid_api_error(error, country_codes = [])
      error_response = JSON.parse(error.response_body) rescue {}
      error_code = error_response["error_code"]
      error_message = error_response["error_message"] || error.message
      region = PlaidConfig.region_for_countries(country_codes)

      Rails.logger.error "Plaid API Error (#{region} region, countries: #{country_codes}): #{error_code} - #{error_message}"

      case error_code
      when "RATE_LIMIT_EXCEEDED"
        raise RateLimitError, "Rate limit exceeded for #{region} region: #{error_message}"
      when "INVALID_CREDENTIALS", "UNAUTHORIZED"
        raise AuthenticationError, "Authentication failed for #{region} region: #{error_message}"
      when "INVALID_REQUEST"
        raise PlaidError, "Invalid request for #{region} region: #{error_message}"
      else
        raise PlaidError, "Plaid API error for #{region} region (#{error_code}): #{error_message}"
      end
    end

    # Get logger for benchmarking
    def logger
      Rails.logger
    end
  end
end
