require "application_system_test_case"

class BankSearchTest < ApplicationSystemTestCase
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

  test "visiting the bank search page" do
    visit bank_search_path

    assert_selector "h1", text: "Bank Connector Search"
    assert_selector "input[placeholder='Enter your bank name...']"
    assert_selector "select", count: 1 # Only Country filter
    assert_text "Start typing to search for banks"
  end

  test "searching for institutions" do
    visit bank_search_path

    # Search for a specific bank
    fill_in "bank-search-input", with: "Test"

    # Wait for search results
    assert_selector "[data-bank-search-target='results']", wait: 2

    # Should show the Test Bank
    within "[data-bank-search-target='results']" do
      assert_text "Test Bank"
    end
  end

  test "filtering by country" do
    visit bank_search_path

    # Filter by Canada
    select "CA", from: "country-filter"

    # Wait for search results
    assert_selector "[data-bank-search-target='results']", wait: 2

    # Should show only Canadian institutions
    within "[data-bank-search-target='results']" do
      assert_text "Another Credit Union"
      assert_no_text "Test Bank"
    end
  end



  test "clearing search with escape key" do
    visit bank_search_path

    # Enter search text
    fill_in "bank-search-input", with: "Test"
    select "US", from: "country-filter"

    # Press escape to clear
    find("#bank-search-input").send_keys(:escape)

    # Should clear all fields
    assert_equal "", find("#bank-search-input").value
    assert_equal "", find("#country-filter").value
  end

  test "clearing search with clear button" do
    visit bank_search_path

    # Enter search text
    fill_in "bank-search-input", with: "Test"

    # Clear button should appear
    assert_selector "[data-bank-search-target='clearButton']:not(.hidden)"

    # Click clear button
    find("[data-bank-search-target='clearButton']").click

    # Should clear the search
    assert_equal "", find("#bank-search-input").value
  end

  test "search stats display" do
    visit bank_search_path

    # Search for something
    fill_in "bank-search-input", with: "Test"

    # Wait for search results and stats
    assert_selector "[data-bank-search-target='searchStats']:not(.hidden)", wait: 2

    # Should show search statistics
    within "[data-bank-search-target='searchStats']" do
      assert_text "Found 1 result for \"Test\""
    end
  end

  test "empty search results" do
    visit bank_search_path

    # Search for something that doesn't exist
    fill_in "bank-search-input", with: "NonExistentBank"

    # Wait for search results
    assert_selector "[data-bank-search-target='results']", wait: 2

    # Should show empty state
    within "[data-bank-search-target='results']" do
      assert_text "No banks found"
      assert_text "Try adjusting your search terms or filters"
    end
  end

  test "responsive design elements" do
    visit bank_search_path

    # Check that responsive classes are present (updated to match actual layout)
    assert_selector ".grid.grid-cols-1.md\\:grid-cols-3"
    assert_selector ".md\\:col-span-2"

    # Check mobile pagination elements (these are only visible when pagination is active)
    # assert_selector ".flex-1.flex.justify-between.sm\\:hidden"
    # assert_selector ".hidden.sm\\:flex-1"
  end
end
