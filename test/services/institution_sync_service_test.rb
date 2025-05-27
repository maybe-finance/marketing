require "test_helper"

class InstitutionSyncServiceTest < ActiveSupport::TestCase
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

    # Clear existing institutions
    Institution.delete_all
  end

  teardown do
    # Restore original environment
    ENV.replace(@original_env)

    # Clear cached clients
    PlaidConfig.instance_variable_set(:@eu_client, nil)
    PlaidConfig.instance_variable_set(:@non_eu_client, nil)

    # Clean up test data
    Institution.delete_all
  end

  test "should have correct country definitions" do
    assert_equal PlaidConfig::EU_COUNTRIES, InstitutionSyncService::EU_COUNTRIES
    assert_equal PlaidConfig::NON_EU_COUNTRIES, InstitutionSyncService::NON_EU_COUNTRIES
    assert_equal PlaidConfig::ALL_SUPPORTED_COUNTRIES, InstitutionSyncService::ALL_SUPPORTED_COUNTRIES
  end

  test "sync_all_institutions should handle single region" do
    country_codes = %w[US]

    PlaidConfig.expects(:region_for_countries).with(country_codes).returns(:non_eu)
    InstitutionSyncService.expects(:sync_single_region).with(
      country_codes: country_codes,
      products: nil
    ).returns({
      created: 5,
      updated: 3,
      total_processed: 8,
      errors: [],
      region: :non_eu,
      duration: 2.5
    })

    result = InstitutionSyncService.sync_all_institutions(country_codes: country_codes)

    assert_equal 5, result[:created]
    assert_equal 3, result[:updated]
    assert_equal :non_eu, result[:region]
  end

  test "sync_all_institutions should handle mixed regions" do
    country_codes = %w[US ES]

    PlaidConfig.expects(:region_for_countries).with(country_codes).returns(:mixed)
    InstitutionSyncService.expects(:sync_mixed_regions).with(
      country_codes: country_codes,
      products: nil
    ).returns({
      created: 10,
      updated: 5,
      total_processed: 15,
      errors: [],
      regions: {
        eu: { created: 5, updated: 2 },
        non_eu: { created: 5, updated: 3 }
      },
      mixed_region: true,
      duration: 5.0
    })

    result = InstitutionSyncService.sync_all_institutions(country_codes: country_codes)

    assert_equal 10, result[:created]
    assert_equal 5, result[:updated]
    assert result[:mixed_region]
  end

  test "sync_by_region should work for eu region" do
    PlaidConfig.expects(:eu_configured?).returns(true)
    InstitutionSyncService.expects(:sync_single_region).with(
      country_codes: InstitutionSyncService::EU_COUNTRIES,
      products: nil,
      region: :eu
    ).returns({
      created: 5,
      updated: 3,
      total_processed: 8,
      errors: [],
      region: :eu,
      duration: 2.5
    })

    result = InstitutionSyncService.sync_by_region(:eu)

    assert_equal 5, result[:created]
    assert_equal :eu, result[:region]
  end

  test "sync_by_region should handle missing credentials" do
    PlaidConfig.expects(:eu_configured?).returns(false)

    result = InstitutionSyncService.sync_by_region(:eu)

    assert result[:skipped]
    assert_includes result[:errors].first, "EU credentials not configured"
  end

  test "sync_by_region should raise error for invalid region" do
    assert_raises(ArgumentError) do
      InstitutionSyncService.sync_by_region(:invalid)
    end
  end

  test "sync_countries should call sync_all_institutions" do
    country_codes = %w[US CA GB]

    InstitutionSyncService.expects(:sync_all_institutions).with(
      country_codes: country_codes,
      products: nil
    ).returns({ created: 5, updated: 3 })

    result = InstitutionSyncService.sync_countries(country_codes)
    assert_equal 5, result[:created]
  end

  test "sync_country should call sync_countries with single country" do
    InstitutionSyncService.expects(:sync_countries).with(
      [ "US" ],
      products: nil
    ).returns({ created: 2, updated: 1 })

    result = InstitutionSyncService.sync_country("US")
    assert_equal 2, result[:created]
  end

  test "sync_institutions should create new institutions" do
    plaid_institutions = [
      mock_plaid_institution(institution_id: "bank1", name: "Bank One"),
      mock_plaid_institution(institution_id: "bank2", name: "Bank Two")
    ]

    result = InstitutionSyncService.send(:sync_institutions, plaid_institutions)

    assert_equal 2, result[:created]
    assert_equal 0, result[:updated]
    assert_equal 2, result[:total_processed]
    assert_empty result[:errors]

    assert_equal 2, Institution.count
    assert Institution.find_by(institution_id: "bank1")
    assert Institution.find_by(institution_id: "bank2")
  end

  test "sync_institutions should update existing institutions" do
    # Create existing institution
    Institution.create!(
      institution_id: "bank1",
      name: "Old Bank Name",
      country_codes: [ "US" ],
      products: [ "auth" ],

    )

    plaid_institutions = [
      mock_plaid_institution(institution_id: "bank1", name: "New Bank Name")
    ]

    result = InstitutionSyncService.send(:sync_institutions, plaid_institutions)

    assert_equal 0, result[:created]
    assert_equal 1, result[:updated]
    assert_equal 1, result[:total_processed]
    assert_empty result[:errors]

    institution = Institution.find_by(institution_id: "bank1")
    assert_equal "New Bank Name", institution.name
  end

  test "sync_institutions should handle errors gracefully" do
    # Mock an institution that will cause an error
    bad_institution = mock("bad_institution")
    bad_institution.stubs(:institution_id).returns("bad_bank")
    bad_institution.stubs(:name).raises(StandardError.new("API Error"))

    plaid_institutions = [
      mock_plaid_institution(institution_id: "good_bank", name: "Good Bank"),
      bad_institution
    ]

    result = InstitutionSyncService.send(:sync_institutions, plaid_institutions)

    assert_equal 1, result[:created]
    assert_equal 0, result[:updated]
    assert_equal 2, result[:total_processed]
    assert_equal 1, result[:errors].length
    assert_includes result[:errors].first, "bad_bank"
  end

  test "convert_plaid_institution should extract all fields correctly" do
    plaid_institution = mock_plaid_institution(
      institution_id: "test_bank",
      name: "  Test Bank  ", # Test trimming
      country_codes: [ "US", "CA" ]
    )

    result = InstitutionSyncService.send(:convert_plaid_institution, plaid_institution)

    assert_equal "test_bank", result[:institution_id]
    assert_equal "Test Bank", result[:name] # Should be trimmed
    assert_equal [ "US", "CA" ], result[:country_codes]
    assert_equal [ "transactions" ], result[:products]
    assert_equal "https://testbank.com", result[:website]
    assert_equal false, result[:oauth]
    assert_equal "#000000", result[:primary_color]
    assert_not result.key?(:status)
  end

  test "test_sync should work with single region" do
    PlaidConfig.expects(:region_for_countries).with(%w[US]).returns(:non_eu)

    PlaidService.expects(:fetch_institutions).with(
      count: 5,
      country_codes: %w[US],
      products: nil
    ).returns({
      total: 100,
      institutions: [ mock_plaid_institution ]
    })

    InstitutionSyncService.expects(:sync_institutions).returns({
      created: 1,
      updated: 0,
      errors: []
    })

    result = InstitutionSyncService.test_sync(count: 5, country_codes: %w[US])

    assert_equal 100, result[:plaid_fetch][:total_available]
    assert_equal 1, result[:plaid_fetch][:fetched]
    assert_equal %w[US], result[:plaid_fetch][:countries]
    assert_equal :non_eu, result[:plaid_fetch][:region]
    assert_equal 1, result[:sync_result][:created]
  end

  test "test_sync should handle errors" do
    PlaidService.expects(:fetch_institutions).raises(PlaidService::AuthenticationError.new("Invalid credentials"))

    result = InstitutionSyncService.test_sync(count: 5, country_codes: %w[US])

    assert_includes result[:plaid_fetch][:error], "Invalid credentials"
    assert_equal 0, result[:sync_result][:created]
    assert_equal 1, result[:sync_result][:errors].length
  end

  test "sync_stats should include region breakdown" do
    # Create test institutions
    Institution.create!(
      institution_id: "us_bank",
      name: "US Bank",
      country_codes: [ "US" ],
      products: [ "transactions" ],

    )

    Institution.create!(
      institution_id: "eu_bank",
      name: "EU Bank",
      country_codes: [ "ES" ],
      products: [ "transactions" ],

    )

    PlaidConfig.expects(:eu_configured?).returns(true)
    PlaidConfig.expects(:non_eu_configured?).returns(true)

    stats = InstitutionSyncService.sync_stats

    assert_equal 2, stats[:total_institutions]
    assert_equal 1, stats[:by_region][:non_eu]
    assert_equal 1, stats[:by_region][:eu]
    assert stats[:configuration][:eu_configured]
    assert stats[:configuration][:non_eu_configured]
    assert_equal({ "US" => 1, "ES" => 1 }, stats[:by_country])
  end

  test "sync_single_region should handle authentication errors" do
    country_codes = %w[US]

    PlaidService.expects(:fetch_all_institutions).with(
      country_codes: country_codes,
      products: nil
    ).raises(PlaidService::AuthenticationError.new("Invalid credentials"))

    result = InstitutionSyncService.send(:sync_single_region,
      country_codes: country_codes,
      products: nil,
      region: :non_eu
    )

    assert result[:failed]
    assert_includes result[:errors].first, "Authentication failed"
    assert_equal :non_eu, result[:region]
  end

  test "sync_single_region should handle rate limit errors" do
    country_codes = %w[US]

    PlaidService.expects(:fetch_all_institutions).with(
      country_codes: country_codes,
      products: nil
    ).raises(PlaidService::RateLimitError.new("Rate limit exceeded"))

    result = InstitutionSyncService.send(:sync_single_region,
      country_codes: country_codes,
      products: nil,
      region: :non_eu
    )

    assert result[:rate_limited]
    assert_includes result[:errors].first, "Rate limit exceeded"
  end

  test "sync_mixed_regions should handle both regions" do
    country_codes = %w[US ES]

    # Mock configuration
    PlaidConfig.expects(:eu_configured?).returns(true)
    PlaidConfig.expects(:non_eu_configured?).returns(true)

    # Mock region syncs
    InstitutionSyncService.expects(:sync_single_region).with(
      country_codes: %w[ES],
      products: nil,
      region: :eu
    ).returns({
      created: 3,
      updated: 1,
      total_processed: 4,
      errors: []
    })

    InstitutionSyncService.expects(:sync_single_region).with(
      country_codes: %w[US],
      products: nil,
      region: :non_eu
    ).returns({
      created: 2,
      updated: 1,
      total_processed: 3,
      errors: []
    })

    result = InstitutionSyncService.send(:sync_mixed_regions,
      country_codes: country_codes,
      products: nil
    )

    assert_equal 5, result[:created]
    assert_equal 2, result[:updated]
    assert_equal 7, result[:total_processed]
    assert result[:mixed_region]
    assert result[:regions][:eu]
    assert result[:regions][:non_eu]
  end

  test "sync_mixed_regions should handle missing credentials" do
    country_codes = %w[US ES]

    # Mock configuration - only non-EU configured
    PlaidConfig.expects(:eu_configured?).returns(false)
    PlaidConfig.expects(:non_eu_configured?).returns(true)

    # Mock only non-EU sync
    InstitutionSyncService.expects(:sync_single_region).with(
      country_codes: %w[US],
      products: nil,
      region: :non_eu
    ).returns({
      created: 2,
      updated: 1,
      total_processed: 3,
      errors: []
    })

    result = InstitutionSyncService.send(:sync_mixed_regions,
      country_codes: country_codes,
      products: nil
    )

    assert_equal 2, result[:created]
    assert_equal 1, result[:updated]
    assert_equal 1, result[:errors].length
    assert_includes result[:errors].first, "EU countries requested but EU credentials not configured"
    assert result[:regions][:eu][:skipped]
    assert result[:regions][:non_eu]
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
    institution.stubs(:respond_to?).with(:logo).returns(true)
    institution.stubs(:respond_to?).with(:url).returns(true)
    institution.stubs(:respond_to?).with(:oauth).returns(true)
    institution.stubs(:respond_to?).with(:primary_color).returns(true)
    institution.stubs(:respond_to?).with(:status).returns(true)
    institution
  end
end
