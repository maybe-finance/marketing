require "test_helper"

class RedirectTest < ActiveSupport::TestCase
  test "should require source_path" do
    redirect = Redirect.new(destination_path: "/new-path")
    assert_not redirect.valid?
    assert_includes redirect.errors[:source_path], "can't be blank"
  end

  test "should require destination_path" do
    redirect = Redirect.new(source_path: "/old-path")
    assert_not redirect.valid?
    assert_includes redirect.errors[:destination_path], "can't be blank"
  end

  test "should require unique source_path" do
    Redirect.create!(source_path: "/old-path", destination_path: "/new-path", redirect_type: "permanent", pattern_type: "exact", priority: 1)
    redirect = Redirect.new(source_path: "/old-path", destination_path: "/another-path", redirect_type: "permanent", pattern_type: "exact", priority: 2)
    assert_not redirect.valid?
    assert_includes redirect.errors[:source_path], "has already been taken"
  end

  test "should validate redirect_type inclusion" do
    redirect = Redirect.new(source_path: "/old", destination_path: "/new", redirect_type: "invalid")
    assert_not redirect.valid?
    assert_includes redirect.errors[:redirect_type], "is not included in the list"
  end

  test "should validate pattern_type inclusion" do
    redirect = Redirect.new(source_path: "/old", destination_path: "/new", pattern_type: "invalid")
    assert_not redirect.valid?
    assert_includes redirect.errors[:pattern_type], "is not included in the list"
  end

  test "status_code returns 301 for permanent redirects" do
    redirect = Redirect.new(redirect_type: "permanent")
    assert_equal 301, redirect.status_code
  end

  test "status_code returns 302 for temporary redirects" do
    redirect = Redirect.new(redirect_type: "temporary")
    assert_equal 302, redirect.status_code
  end

  test "matches_path? works with exact pattern" do
    redirect = Redirect.new(source_path: "/old-path", pattern_type: "exact")
    assert redirect.matches_path?("/old-path")
    assert_not redirect.matches_path?("/old-path/sub")
    assert_not redirect.matches_path?("/different")
  end

  test "matches_path? works with wildcard pattern" do
    redirect = Redirect.new(source_path: "/blog/*", pattern_type: "wildcard")
    assert redirect.matches_path?("/blog/post-1")
    assert redirect.matches_path?("/blog/category/tech")
    assert_not redirect.matches_path?("/news/article")
  end

  test "matches_path? works with regex pattern" do
    redirect = Redirect.new(source_path: "^/blog/(\\d+)", pattern_type: "regex")
    assert redirect.matches_path?("/blog/123")
    assert redirect.matches_path?("/blog/456/comments")
    assert_not redirect.matches_path?("/blog/abc")
  end

  test "matches_path? handles invalid regex gracefully" do
    redirect = Redirect.new(source_path: "[invalid", pattern_type: "regex")
    assert_not redirect.matches_path?("/any-path")
  end

  test "process_destination works with exact and wildcard patterns" do
    redirect = Redirect.new(destination_path: "/new-path", pattern_type: "exact")
    assert_equal "/new-path", redirect.process_destination("/old-path")
  end

  test "process_destination works with regex pattern" do
    redirect = Redirect.new(
      source_path: "^/blog/(\\d+)",
      destination_path: "/posts/\\1",
      pattern_type: "regex"
    )
    assert_equal "/posts/123", redirect.process_destination("/blog/123")
  end

  test "process_destination handles invalid regex gracefully" do
    redirect = Redirect.new(
      source_path: "[invalid",
      destination_path: "/fallback",
      pattern_type: "regex"
    )
    assert_equal "/fallback", redirect.process_destination("/any-path")
  end

  test "active scope returns only active redirects" do
    active_redirect = Redirect.create!(
      source_path: "/active",
      destination_path: "/new",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: true,
      priority: 1
    )

    inactive_redirect = Redirect.create!(
      source_path: "/inactive",
      destination_path: "/new",
      redirect_type: "permanent",
      pattern_type: "exact",
      active: false,
      priority: 1
    )

    active_redirects = Redirect.active
    assert_includes active_redirects, active_redirect
    assert_not_includes active_redirects, inactive_redirect
  end

  test "by_priority scope orders by priority" do
    Redirect.delete_all

    low_priority = Redirect.create!(
      source_path: "/low",
      destination_path: "/new",
      redirect_type: "permanent",
      pattern_type: "exact",
      priority: 10
    )

    high_priority = Redirect.create!(
      source_path: "/high",
      destination_path: "/new",
      redirect_type: "permanent",
      pattern_type: "exact",
      priority: 1
    )

    redirects = Redirect.by_priority
    assert_equal high_priority, redirects.first
    assert_equal low_priority, redirects.last
  end
end
