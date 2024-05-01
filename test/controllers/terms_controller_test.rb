require "test_helper"

class TermsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get terms_index_url
    assert_response :success
  end

  test "should get show" do
    get terms_show_url
    assert_response :success
  end
end
