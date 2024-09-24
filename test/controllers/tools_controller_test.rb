require "test_helper"

class ToolsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get tools_url
    assert_response :success
  end

  test "show" do
    get tool_url("roi-calculator")
    assert_response :success
  end

  test "show with evil intentions" do
    get tool_url("inaccessible-tool")
    assert_response :not_found
  end
end
