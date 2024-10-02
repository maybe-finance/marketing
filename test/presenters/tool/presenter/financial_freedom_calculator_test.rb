require "test_helper"

class Tool::Presenter::FinancialFreedomCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::FinancialFreedomCalculator.new \
      annual_savings_growth_rate: "8.00",
      current_savings: "$200,000.00",
      monthly_expenses: "$5,000.00"
  end

  test "blankness" do
    assert Tool::Presenter::FinancialFreedomCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "free forever" do
    assert_not @tool.free_forever?
    assert Tool::Presenter::FinancialFreedomCalculator.new(
      current_savings: "$10,000,000.00",
      monthly_expenses: "$5,000.00",
      annual_savings_growth_rate: "10.00"
    ).free_forever?
  end

  test "plot data" do
    travel_to Date.new(2024, 9, 24) do
      first_plot_point = {
        date: Date.today,
        savingsRemaining: 200_000.00,
        monthlyExpenditure: 5_000.00 }
      last_plot_point = {
        date: Date.new(2028, 8, 24),
        savingsRemaining: 0.00,
        monthlyExpenditure: 5_000.00 }

      assert_equal first_plot_point, @tool.plot_data.first
      assert_equal last_plot_point, @tool.plot_data.last
    end
  end

  test "seconds left" do
    assert_equal 125_385_891.85, @tool.seconds_left.round(2)
  end
end
