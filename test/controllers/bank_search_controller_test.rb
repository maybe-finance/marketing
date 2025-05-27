require "test_helper"

class BankSearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Clear existing institutions to avoid interference
    Institution.delete_all

    # Create test institutions
    @institution1 = Institution.create!(
      institution_id: "test_001",
      name: "Test Bank",
      country_codes: [ "US" ],
      products: [ "auth", "transactions" ]
    )

    @institution2 = Institution.create!(
      institution_id: "test_002",
      name: "Another Credit Union",
      country_codes: [ "CA" ],
      products: [ "balance", "identity" ]
    )
  end

  test "should get index" do
    get bank_search_path
    assert_response :success
    assert_select "h1", "Bank Connector Search"
  end

  test "should return all institutions when no filters" do
    get bank_search_api_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["institutions"].is_a?(Array)
    assert json_response["pagination"].present?
    assert json_response["filters"].present?
  end

  test "should filter institutions by name query" do
    get bank_search_api_path, params: { query: "Test" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    institutions = json_response["institutions"]

    assert_equal 1, institutions.length
    assert_equal "Test Bank", institutions.first["name"]
  end

  test "should filter institutions by country" do
    get bank_search_api_path, params: { country: "CA" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    institutions = json_response["institutions"]

    assert_equal 1, institutions.length
    assert_equal "Another Credit Union", institutions.first["name"]
  end



  test "should return empty results for non-matching query" do
    get bank_search_api_path, params: { query: "NonExistentBank" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 0, json_response["institutions"].length
    assert_equal 0, json_response["pagination"]["total_count"]
  end

  test "should handle pagination parameters" do
    get bank_search_api_path, params: { page: 1, per_page: 1 }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 1, pagination["current_page"]
    assert_equal 1, pagination["per_page"]
    assert pagination["total_count"] >= 1
  end

  test "should limit per_page to maximum of 50" do
    get bank_search_api_path, params: { per_page: 100 }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 50, json_response["pagination"]["per_page"]
  end

  test "should handle search errors gracefully" do
    # Mock an error in the search process
    Institution.stubs(:all).raises(StandardError.new("Database error"))

    get bank_search_api_path, as: :json
    assert_response :internal_server_error

    json_response = JSON.parse(response.body)
    assert_equal "Search failed", json_response["error"]
  end
end
