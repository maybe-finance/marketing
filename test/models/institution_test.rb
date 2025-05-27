require "test_helper"

class InstitutionTest < ActiveSupport::TestCase
  def setup
    @test_institution = Institution.new(
      institution_id: "test_001",
      name: "Test Bank",
      country_codes: [ "US" ],
      products: [ "auth" ]
    )

    @another_institution = Institution.new(
      institution_id: "test_002",
      name: "Another Bank",
      country_codes: [ "US", "CA" ],
      products: [ "auth", "transactions" ]
    )
  end

  test "to_search_result includes basic information" do
    result = @test_institution.to_search_result

    assert_equal "test_001", result[:institution_id]
    assert_equal "Test Bank", result[:name]
    assert_equal [ "US" ], result[:country_codes]
    assert_equal [ "auth" ], result[:products]
    assert_not result.key?(:status)
  end

  test "supports_product? works correctly" do
    assert @another_institution.supports_product?("auth")
    assert @another_institution.supports_product?("transactions")
    assert_not @another_institution.supports_product?("balance")
  end

  test "available_in_country? works correctly" do
    assert @another_institution.available_in_country?("US")
    assert @another_institution.available_in_country?("CA")
    assert_not @another_institution.available_in_country?("GB")
  end

    test "search scope works correctly" do
    # Clear existing institutions to avoid interference
    Institution.delete_all

    # Create test institutions in database
    Institution.create!(
      institution_id: "search_test_1",
      name: "Chase Bank",
      country_codes: [ "US" ],
      products: [ "auth" ]
    )

    Institution.create!(
      institution_id: "search_test_2",
      name: "Bank of America",
      country_codes: [ "US" ],
      products: [ "transactions" ]
    )

    results = Institution.search("Chase")
    assert_equal 1, results.count
    assert_equal "Chase Bank", results.first.name

    results = Institution.search("Bank")
    assert_equal 2, results.count
  end
end
