require "plaid"

# Plaid API Configuration with Multi-Region Support
module PlaidConfig
  # Define supported regions and their corresponding country codes
  # Note: GB (United Kingdom) uses the non-EU endpoint despite being in Europe
  EU_COUNTRIES = %w[ES NL FR IE DE IT PL DK NO SE EE LT LV PT BE AT FI].freeze
      NON_EU_COUNTRIES = %w[US CA].freeze
  ALL_SUPPORTED_COUNTRIES = (EU_COUNTRIES + NON_EU_COUNTRIES).freeze

  class << self
    # Get the appropriate Plaid client for a region
    # @param region [Symbol] :eu or :non_eu
    # @return [Plaid::PlaidApi] Configured Plaid API client
    def client(region = :non_eu)
      case region
      when :eu
        eu_client
      when :non_eu
        non_eu_client
      else
        raise ArgumentError, "Invalid region: #{region}. Must be :eu or :non_eu"
      end
    end

    # Get the appropriate client based on country codes
    # @param country_codes [Array<String>] Array of country codes
    # @return [Plaid::PlaidApi] Configured Plaid API client
    def client_for_countries(country_codes)
      # If any country is EU, use EU client; otherwise use non-EU client
      if country_codes.any? { |code| EU_COUNTRIES.include?(code) }
        client(:eu)
      else
        client(:non_eu)
      end
    end

    # Determine region for a set of country codes
    # @param country_codes [Array<String>] Array of country codes
    # @return [Symbol] :eu, :non_eu, or :mixed
    def region_for_countries(country_codes)
      eu_countries = country_codes & EU_COUNTRIES
      non_eu_countries = country_codes & NON_EU_COUNTRIES

      if eu_countries.any? && non_eu_countries.any?
        :mixed
      elsif eu_countries.any?
        :eu
      else
        :non_eu
      end
    end

    # Check if EU credentials are configured
    def eu_configured?
      ENV["PLAID_EU_CLIENT_ID"].present? && ENV["PLAID_EU_SECRET"].present?
    end

    # Check if non-EU credentials are configured
    def non_eu_configured?
      ENV["PLAID_CLIENT_ID"].present? && ENV["PLAID_SECRET"].present?
    end

    private

    def eu_client
      @eu_client ||= build_client(
        client_id: eu_client_id,
        secret: eu_secret
      )
    end

    def non_eu_client
      @non_eu_client ||= build_client(
        client_id: client_id,
        secret: secret
      )
    end

    def build_client(client_id:, secret:)
      configuration = Plaid::Configuration.new
      configuration.server_index = environment_index
      configuration.api_key["PLAID-CLIENT-ID"] = client_id
      configuration.api_key["PLAID-SECRET"] = secret

      api_client = Plaid::ApiClient.new(configuration)
      Plaid::PlaidApi.new(api_client)
    end

    # EU credentials
    def eu_client_id
      ENV["PLAID_EU_CLIENT_ID"] || raise("PLAID_EU_CLIENT_ID environment variable is required for EU operations")
    end

    def eu_secret
      ENV["PLAID_EU_SECRET"] || raise("PLAID_EU_SECRET environment variable is required for EU operations")
    end

    # Non-EU credentials (existing)
    def client_id
      ENV["PLAID_CLIENT_ID"] || raise("PLAID_CLIENT_ID environment variable is required")
    end

    def secret
      ENV["PLAID_SECRET"] || raise("PLAID_SECRET environment variable is required")
    end

    def environment
      ENV.fetch("PLAID_ENVIRONMENT", "sandbox")
    end

    def environment_index
      case environment
      when "sandbox"
        Plaid::Configuration::Environment["sandbox"]
      when "development"
        Plaid::Configuration::Environment["development"]
      when "production"
        Plaid::Configuration::Environment["production"]
      else
        raise "Invalid PLAID_ENVIRONMENT: #{environment}. Must be sandbox, development, or production"
      end
    end
  end
end

# Make the clients available globally and test configuration
Rails.application.config.after_initialize do
  # Test the configuration in development
  if Rails.env.development?
    begin
      # Test non-EU client if configured
      if PlaidConfig.non_eu_configured?
        PlaidConfig.client(:non_eu)
        Rails.logger.info "✅ Plaid non-EU client initialized successfully for #{ENV.fetch('PLAID_ENVIRONMENT', 'sandbox')} environment"
      else
        Rails.logger.warn "⚠️  Plaid non-EU client not configured (missing PLAID_CLIENT_ID or PLAID_SECRET)"
      end

      # Test EU client if configured
      if PlaidConfig.eu_configured?
        PlaidConfig.client(:eu)
        Rails.logger.info "✅ Plaid EU client initialized successfully for #{ENV.fetch('PLAID_ENVIRONMENT', 'sandbox')} environment"
      else
        Rails.logger.warn "⚠️  Plaid EU client not configured (missing PLAID_EU_CLIENT_ID or PLAID_EU_SECRET)"
      end
    rescue => e
      Rails.logger.warn "⚠️  Plaid client initialization failed: #{e.message}"
    end
  end
end
