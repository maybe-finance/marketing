require "test_helper"

class PlaidServiceTest < ActiveSupport::TestCase
  setup do
    # Mock environment variables for testing
    @original_env = ENV.to_h
    ENV["PLAID_CLIENT_ID"] = "test_non_eu_client_id"
    ENV["PLAID_SECRET"] = "test_non_eu_secret"
    ENV["PLAID_EU_CLIENT_ID"] = "test_eu_client_id"
    ENV["PLAID_EU_SECRET"] = "test_eu_secret"
    ENV["PLAID_ENVIRONMENT"] = "sandbox"

    # Clear any cached clients
    PlaidConfig.instance_variable_set(:@eu_client, nil)
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)
  end

  teardown do
    # Restore original environment
    ENV.replace(@original_env)

    # Clear cached clients
    PlaidConfig.instance_variable_set(:@eu_client, nil)
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)
  end

  test "should have correct country definitions" do
    assert_equal %w[ES NL FR IE DE IT PL DK NO SE EE LT LV PT BE AT FI], PlaidService::EU_COUNTRIES
    assert_equal %w[US CA GB], PlaidService::NON_EU_COUNTRIES
    assert_equal 19, PlaidService::ALL_SUPPORTED_COUNTRIES.length
  end

  test "client should return appropriate client for country codes" do
    # Mock PlaidConfig.client_for_countries
    PlaidConfig.expects(:client_for_countries).with(%w[US]).returns("non_eu_client")
    assert_equal "non_eu_client", PlaidService.client(%w[US])

    PlaidConfig.expects(:client_for_countries).with(%w[ES]).returns("eu_client")
    assert_equal "eu_client", PlaidService.client(%w[ES])
  end

  test "fetch_institutions should handle single region requests" do
    # Mock PlaidConfig and API response
    mock_client = mock("plaid_client")
    mock_response = mock("response")
    mock_response.stubs(:institutions).returns([])
    mock_response.stubs(:total).returns(0)

    PlaidConfig.expects(:region_for_countries).with(%w[US]).returns(:non_eu)
    PlaidService.expects(:fetch_institutions_single_region).with(
      count: 500,
      offset: 0,
      country_codes: %w[US],
      products: nil
    ).returns({
      institutions: [],
      total: 0,
      count: 0,
      offset: 0,
      has_more: false
    })

    result = PlaidService.fetch_institutions(country_codes: %w[US])
    assert_equal 0, result[:total]
    assert_equal [], result[:institutions]
  end

  test "fetch_institutions should handle mixed region requests" do
    mixed_countries = %w[US ES]

    PlaidConfig.expects(:region_for_countries).with(mixed_countries).returns(:mixed)
    PlaidService.expects(:fetch_institutions_mixed_regions).with(
      count: 500,
      offset: 0,
      country_codes: mixed_countries,
      products: nil
    ).returns({
      institutions: [],
      total: 0,
      count: 0,
      offset: 0,
      has_more: false
    })

    result = PlaidService.fetch_institutions(country_codes: mixed_countries)
    assert_equal 0, result[:total]
  end

  test "fetch_all_institutions should handle single region" do
    PlaidConfig.expects(:region_for_countries).with(%w[US]).returns(:non_eu)
    PlaidService.expects(:fetch_all_institutions_single_region).with(
      country_codes: %w[US],
      products: nil,
      batch_size: 500
    ).returns([])

    result = PlaidService.fetch_all_institutions(country_codes: %w[US])
    assert_equal [], result
  end

  test "fetch_all_institutions should handle mixed regions" do
    mixed_countries = %w[US ES]

    PlaidConfig.expects(:region_for_countries).with(mixed_countries).returns(:mixed)
    PlaidService.expects(:fetch_all_institutions_mixed_regions).with(
      country_codes: mixed_countries,
      products: nil,
      batch_size: 500
    ).returns([])

    result = PlaidService.fetch_all_institutions(country_codes: mixed_countries)
    assert_equal [], result
  end

  test "fetch_institutions_by_country should call fetch_all_institutions" do
    PlaidService.expects(:fetch_all_institutions).with(
      country_codes: [ "US" ],
      products: nil
    ).returns([])

    result = PlaidService.fetch_institutions_by_country("US")
    assert_equal [], result
  end

  test "fetch_institutions_by_region should work for eu region" do
    PlaidService.expects(:fetch_all_institutions).with(
      country_codes: PlaidService::EU_COUNTRIES,
      products: nil
    ).returns([])

    result = PlaidService.fetch_institutions_by_region(:eu)
    assert_equal [], result
  end

  test "fetch_institutions_by_region should work for non_eu region" do
    PlaidService.expects(:fetch_all_institutions).with(
      country_codes: PlaidService::NON_EU_COUNTRIES,
      products: nil
    ).returns([])

    result = PlaidService.fetch_institutions_by_region(:non_eu)
    assert_equal [], result
  end

  test "fetch_institutions_by_region should raise error for invalid region" do
    assert_raises(ArgumentError) do
      PlaidService.fetch_institutions_by_region(:invalid)
    end
  end

  test "test_connection should work for non_eu region" do
    # Mock successful connection
    PlaidService.expects(:fetch_institutions).with(
      count: 1,
      offset: 0,
      country_codes: [ "US" ]
    ).returns({ total: 100 })

    result = PlaidService.test_connection(:non_eu)
    assert result[:success]
    assert_equal :non_eu, result[:region]
    assert_equal 100, result[:total_institutions]
  end

  test "test_connection should handle errors" do
    # Mock failed connection
    PlaidService.expects(:fetch_institutions).with(
      count: 1,
      offset: 0,
      country_codes: [ "US" ]
    ).raises(PlaidService::AuthenticationError.new("Invalid credentials"))

    result = PlaidService.test_connection(:non_eu)
    assert_not result[:success]
    assert_equal :non_eu, result[:region]
    assert_includes result[:message], "Invalid credentials"
  end

  test "test_all_connections should test both regions" do
    # Mock configuration checks
    PlaidConfig.expects(:non_eu_configured?).returns(true)
    PlaidConfig.expects(:eu_configured?).returns(true)

    # Mock individual connection tests
    PlaidService.expects(:test_connection).with(:non_eu).returns({
      success: true,
      region: :non_eu
    })
    PlaidService.expects(:test_connection).with(:eu).returns({
      success: true,
      region: :eu
    })

    results = PlaidService.test_all_connections
    assert results[:non_eu][:success]
    assert results[:eu][:success]
  end

  test "test_all_connections should handle missing credentials" do
    # Mock configuration checks
    PlaidConfig.expects(:non_eu_configured?).returns(false)
    PlaidConfig.expects(:eu_configured?).returns(false)

    results = PlaidService.test_all_connections
    assert_not results[:non_eu][:success]
    assert_not results[:eu][:success]
    assert_includes results[:non_eu][:message], "not configured"
    assert_includes results[:eu][:message], "not configured"
  end

  test "error handling should include region context" do
    # Mock Plaid API error
    error_response = {
      "error_code" => "INVALID_CREDENTIALS",
      "error_message" => "Invalid client_id or secret provided"
    }

    plaid_error = Plaid::ApiError.new
    plaid_error.stubs(:response_body).returns(error_response.to_json)

    country_codes = %w[US]

    assert_raises(PlaidService::AuthenticationError) do
      PlaidService.send(:handle_plaid_api_error, plaid_error, country_codes)
    end
  end

  test "error handling should handle rate limits" do
    error_response = {
      "error_code" => "RATE_LIMIT_EXCEEDED",
      "error_message" => "Rate limit exceeded"
    }

    plaid_error = Plaid::ApiError.new
    plaid_error.stubs(:response_body).returns(error_response.to_json)

    country_codes = %w[ES]

    assert_raises(PlaidService::RateLimitError) do
      PlaidService.send(:handle_plaid_api_error, plaid_error, country_codes)
    end
  end

  test "error handling should handle network errors" do
    assert_raises(PlaidService::NetworkError) do
      PlaidService.send(:with_error_handling, %w[US]) do
        raise Faraday::TimeoutError.new("Request timeout")
      end
    end
  end

  test "error handling should handle unexpected errors" do
    assert_raises(PlaidService::PlaidError) do
      PlaidService.send(:with_error_handling, %w[US]) do
        raise StandardError.new("Unexpected error")
      end
    end
  end

  private

  def mock_plaid_institution(institution_id: "test_bank", name: "Test Bank", country_codes: [ "US" ])
    institution = mock("plaid_institution")
    institution.stubs(:institution_id).returns(institution_id)
    institution.stubs(:name).returns(name)
    institution.stubs(:country_codes).returns(country_codes)
    institution.stubs(:products).returns([ "transactions" ])
    institution.stubs(:logo).returns(nil)
    institution.stubs(:url).returns("https://testbank.com")
    institution.stubs(:oauth).returns(false)
    institution.stubs(:primary_color).returns("#000000")
    institution.stubs(:status).returns(nil)
    institution
  end
end
