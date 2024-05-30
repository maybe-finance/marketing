require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stocks_index_url
    assert_response :success
  end

  test "should get show" do
    get stocks_show_url
    assert_response :success
  end
end
