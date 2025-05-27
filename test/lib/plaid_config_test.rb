require "test_helper"

class PlaidConfigTest < ActiveSupport::TestCase
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
    expected_eu_countries = %w[ES NL FR IE DE IT PL DK NO SE EE LT LV PT BE AT FI]
    expected_non_eu_countries = %w[US CA GB]

    assert_equal expected_eu_countries, PlaidConfig::EU_COUNTRIES
    assert_equal expected_non_eu_countries, PlaidConfig::NON_EU_COUNTRIES
    assert_equal 19, PlaidConfig::ALL_SUPPORTED_COUNTRIES.length

    # Ensure no overlap between regions
    assert_empty PlaidConfig::EU_COUNTRIES & PlaidConfig::NON_EU_COUNTRIES

    # Ensure all countries are included
    all_countries = PlaidConfig::EU_COUNTRIES + PlaidConfig::NON_EU_COUNTRIES
    assert_equal all_countries.sort, PlaidConfig::ALL_SUPPORTED_COUNTRIES.sort
  end

  test "client should return non_eu client by default" do
    client = PlaidConfig.client
    assert_not_nil client
    assert_instance_of Plaid::PlaidApi, client
  end

  test "client should return eu client when specified" do
    client = PlaidConfig.client(:eu)
    assert_not_nil client
    assert_instance_of Plaid::PlaidApi, client
  end

  test "client should return non_eu client when specified" do
    client = PlaidConfig.client(:non_eu)
    assert_not_nil client
    assert_instance_of Plaid::PlaidApi, client
  end

  test "client should raise error for invalid region" do
    assert_raises(ArgumentError) do
      PlaidConfig.client(:invalid)
    end
  end

  test "client_for_countries should return eu client for eu countries" do
    eu_countries = %w[ES FR DE]

    # Mock the client method to verify it's called with :eu
    PlaidConfig.expects(:client).with(:eu).returns("eu_client")

    result = PlaidConfig.client_for_countries(eu_countries)
    assert_equal "eu_client", result
  end

  test "client_for_countries should return non_eu client for non_eu countries" do
    non_eu_countries = %w[US CA GB]

    # Mock the client method to verify it's called with :non_eu
    PlaidConfig.expects(:client).with(:non_eu).returns("non_eu_client")

    result = PlaidConfig.client_for_countries(non_eu_countries)
    assert_equal "non_eu_client", result
  end

  test "client_for_countries should return eu client for mixed countries with eu present" do
    mixed_countries = %w[US ES]

    # Mock the client method to verify it's called with :eu
    PlaidConfig.expects(:client).with(:eu).returns("eu_client")

    result = PlaidConfig.client_for_countries(mixed_countries)
    assert_equal "eu_client", result
  end

  test "region_for_countries should return eu for eu countries" do
    eu_countries = %w[ES FR DE]
    assert_equal :eu, PlaidConfig.region_for_countries(eu_countries)
  end

  test "region_for_countries should return non_eu for non_eu countries" do
    non_eu_countries = %w[US CA GB]
    assert_equal :non_eu, PlaidConfig.region_for_countries(non_eu_countries)
  end

  test "region_for_countries should return mixed for mixed countries" do
    mixed_countries = %w[US ES]
    assert_equal :mixed, PlaidConfig.region_for_countries(mixed_countries)
  end

  test "region_for_countries should return non_eu for empty array" do
    assert_equal :non_eu, PlaidConfig.region_for_countries([])
  end

  test "region_for_countries should return non_eu for unknown countries" do
    unknown_countries = %w[XX YY]
    assert_equal :non_eu, PlaidConfig.region_for_countries(unknown_countries)
  end

  test "eu_configured should return true when eu credentials are present" do
    assert PlaidConfig.eu_configured?
  end

  test "eu_configured should return false when eu credentials are missing" do
    ENV.delete("PLAID_EU_CLIENT_ID")
    assert_not PlaidConfig.eu_configured?

    ENV["PLAID_EU_CLIENT_ID"] = "test_eu_client_id"
    ENV.delete("PLAID_EU_SECRET")
    assert_not PlaidConfig.eu_configured?
  end

  test "non_eu_configured should return true when non_eu credentials are present" do
    assert PlaidConfig.non_eu_configured?
  end

  test "non_eu_configured should return false when non_eu credentials are missing" do
    ENV.delete("PLAID_CLIENT_ID")
    assert_not PlaidConfig.non_eu_configured?

    ENV["PLAID_CLIENT_ID"] = "test_client_id"
    ENV.delete("PLAID_SECRET")
    assert_not PlaidConfig.non_eu_configured?
  end

  test "should cache clients" do
    # First call should create the client
    client1 = PlaidConfig.client(:eu)

    # Second call should return the same cached instance
    client2 = PlaidConfig.client(:eu)

    assert_same client1, client2
  end

  test "should cache different clients for different regions" do
    eu_client = PlaidConfig.client(:eu)
    non_eu_client = PlaidConfig.client(:non_eu)

    assert_not_same eu_client, non_eu_client
  end

  test "should raise error when eu credentials are missing" do
    ENV.delete("PLAID_EU_CLIENT_ID")

    assert_raises(RuntimeError) do
      PlaidConfig.client(:eu)
    end
  end

  test "should raise error when non_eu credentials are missing" do
    ENV.delete("PLAID_CLIENT_ID")

    assert_raises(RuntimeError) do
      PlaidConfig.client(:non_eu)
    end
  end

  test "should use correct environment configuration" do
    # Test sandbox environment
    ENV["PLAID_ENVIRONMENT"] = "sandbox"
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)

    client = PlaidConfig.client(:non_eu)
    assert_not_nil client

    # Test production environment
    ENV["PLAID_ENVIRONMENT"] = "production"
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)

    client = PlaidConfig.client(:non_eu)
    assert_not_nil client
  end

  test "should raise error for invalid environment" do
    ENV["PLAID_ENVIRONMENT"] = "invalid"
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)

    assert_raises(RuntimeError) do
      PlaidConfig.client(:non_eu)
    end
  end

  test "should use different credentials for different regions" do
    # Mock Plaid::Configuration to verify different credentials are used
    eu_config = mock("eu_config")
    non_eu_config = mock("non_eu_config")

    Plaid::Configuration.expects(:new).twice.returns(eu_config, non_eu_config)

    # Set up expectations for EU client
    eu_config.expects(:server_index=)
    eu_config.expects(:api_key).returns({})
    eu_api_client = mock("eu_api_client")
    Plaid::ApiClient.expects(:new).with(eu_config).returns(eu_api_client)
    Plaid::PlaidApi.expects(:new).with(eu_api_client).returns("eu_plaid_api")

    # Set up expectations for non-EU client
    non_eu_config.expects(:server_index=)
    non_eu_config.expects(:api_key).returns({})
    non_eu_api_client = mock("non_eu_api_client")
    Plaid::ApiClient.expects(:new).with(non_eu_config).returns(non_eu_api_client)
    Plaid::PlaidApi.expects(:new).with(non_eu_api_client).returns("non_eu_plaid_api")

    # Clear cached clients
    PlaidConfig.instance_variable_set(:@eu_client, nil)
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)

    eu_client = PlaidConfig.client(:eu)
    non_eu_client = PlaidConfig.client(:non_eu)

    assert_equal "eu_plaid_api", eu_client
    assert_equal "non_eu_plaid_api", non_eu_client
  end

  test "should handle edge cases in region detection" do
    # Test with duplicate countries
    assert_equal :eu, PlaidConfig.region_for_countries(%w[ES ES FR])
    assert_equal :non_eu, PlaidConfig.region_for_countries(%w[US US CA GB])
    assert_equal :mixed, PlaidConfig.region_for_countries(%w[US ES US])

    # Test with single countries
    assert_equal :eu, PlaidConfig.region_for_countries(%w[ES])
    assert_equal :non_eu, PlaidConfig.region_for_countries(%w[US])
    assert_equal :non_eu, PlaidConfig.region_for_countries(%w[GB])

    # Test case sensitivity (should be handled by caller, but test current behavior)
    assert_equal :non_eu, PlaidConfig.region_for_countries(%w[us])  # lowercase
    assert_equal :non_eu, PlaidConfig.region_for_countries(%w[gb])  # lowercase
  end
end
