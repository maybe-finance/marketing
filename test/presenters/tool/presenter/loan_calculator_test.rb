require "test_helper"

class Tool::Presenter::LoanCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::LoanCalculator.new \
      loan_amount: "$150,000.00",
      interest_rate: "7.0",
      loan_term: "25",
      loan_period: "years",
      date: "2020-01-24"
  end

  test "blankness" do
    assert Tool::Presenter::LoanCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "monthly payments" do
    assert_equal 1_060.17, @tool.monthly_payments.round(2)
  end

  test "total principal paid" do
    assert_equal 150_000.00, @tool.total_principal_paid
  end

  test "total interest paid" do
    assert_equal 168_050.64, @tool.total_interest_paid.round(2)
  end

  test "total paid" do
    assert_equal 318_050.64, @tool.total_paid.round(2)
  end

  test "total number of payments" do
    assert_equal 300, @tool.total_number_of_payments
  end

  test "estimated payoff date" do
    assert_equal Date.new(2045, 1, 24), @tool.estimated_payoff_date
  end
end
