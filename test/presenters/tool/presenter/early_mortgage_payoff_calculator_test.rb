require "test_helper"

class Tool::Presenter::EarlyMortgagePayoffCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::EarlyMortgagePayoffCalculator.new \
      loan_amount: "$500,000.00",
      extra_payment: "$500.00",
      interest_rate: "6.09",
      savings_rate: "4.00",
      original_term: "30",
      years_left: "30"
  end

  test "blankness" do
    assert Tool::Presenter::EarlyMortgagePayoffCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "mortgage rate 30" do
    MortgageRate::Cache.any_instance.expects(:rate_30).returns("6.09")
    assert_equal "6.09", @tool.mortgage_rate_30
  end

  test "interest savings" do
    assert_equal 204_006.73, @tool.interest_savings.round(2)
  end

  test "total interest" do
    assert_equal 589_628.21, @tool.total_interest.round(2)
  end

  test "total interest with extra payments" do
    assert_equal 385_621.49, @tool.total_interest_with_extra_payments.round(2)
  end

  test "total principal and interest" do
    assert_equal 1_089_628.21, @tool.total_principal_and_interest.round(2)
  end

  test "total principal and interest with extra payments" do
    assert_equal 885_621.49, @tool.total_principal_and_interest_with_extra_payments.round(2)
  end

  test "original payoff date" do
    travel_to Date.new(2024, 9, 24) do
      assert_equal Date.new(2054, 9, 24), @tool.original_payoff_date
    end
  end

  test "new payoff date" do
    travel_to Date.new(2024, 9, 24) do
      assert_equal Date.new(2045, 9, 24), @tool.new_payoff_date
    end
  end

  test "savings accounts balance" do
    assert_equal 197_626.59, @tool.savings_account_balance.round(2)
  end

  test "net difference" do
    assert_equal(-6_380.13, @tool.net_difference.round(2))
  end

  test "time saved" do
    assert_equal "9 years, 0 months", @tool.time_saved
  end
end
