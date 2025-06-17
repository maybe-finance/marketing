require "test_helper"

class TermsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @term = Term.create!(
      name: "Test Term",
      title: "Test Term Title",
      slug: "test-term",
      content: "This is the full content of the test term"
    )
  end

  test "should get index" do
    get terms_url
    assert_response :success
  end

  test "should get index with search query" do
    get terms_url, params: { q: "test" }
    assert_response :success
  end

  test "should get show for existing term" do
    get term_url(@term.slug)
    assert_response :success
  end

  test "should redirect to terms index when term not found" do
    get term_url("non-existent-term")
    assert_redirected_to terms_path
    assert_equal "The financial term you're looking for could not be found.", flash[:alert]
  end
end
