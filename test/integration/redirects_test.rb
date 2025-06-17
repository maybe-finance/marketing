require "test_helper"

class RedirectsTest < ActionDispatch::IntegrationTest
  setup do
    Redirect.delete_all
    @exact_redirect = Redirect.create!(
      source_path: "/old-exact-path",
      destination_path: "/new-exact-path",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: true,
      priority: 1
    )

    @wildcard_redirect = Redirect.create!(
      source_path: "/blog/*",
      destination_path: "/posts",
      redirect_type: "temporary",
      pattern_type: "wildcard",
      active: true,
      priority: 2
    )

    @regex_redirect = Redirect.create!(
      source_path: "^/article/(\\d+)",
      destination_path: "/posts/\\1",
      redirect_type: "permanent",
      pattern_type: "regex",
      active: true,
      priority: 3
    )

    @inactive_redirect = Redirect.create!(
      source_path: "/inactive-path",
      destination_path: "/should-not-redirect",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: false,
      priority: 1
    )
  end

  test "should redirect exact match with correct status code" do
    get "/old-exact-path"
    assert_redirected_to "/new-exact-path"
    assert_response :moved_permanently
  end

  test "should redirect wildcard match with correct status code" do
    get "/blog/some-post"
    assert_redirected_to "/posts"
    assert_response :found
  end

  test "should redirect regex match with captured groups" do
    get "/article/123"
    assert_redirected_to "/posts/123"
    assert_response :moved_permanently
  end

  test "should not redirect inactive redirects" do
    get "/inactive-path"
    assert_response :not_found
  end

  test "should not redirect POST requests" do
    post "/old-exact-path"
    assert_response :not_found
  end

  test "should respect priority order" do
    high_priority = Redirect.create!(
      source_path: "/priority-test-high",
      destination_path: "/high-priority",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: true,
      priority: 1
    )

    low_priority = Redirect.create!(
      source_path: "/priority-test-low",
      destination_path: "/low-priority",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: true,
      priority: 10
    )

    wildcard_redirect = Redirect.create!(
      source_path: "/priority-test*",
      destination_path: "/wildcard-match",
      redirect_type: "permanent",
      pattern_type: "wildcard",
      active: true,
      priority: 5
    )

    get "/priority-test-something"
    assert_redirected_to "/wildcard-match"
  end

  test "should handle paths that don't match any redirects" do
    get "/non-existent-path"
    assert_response :not_found
  end
end
