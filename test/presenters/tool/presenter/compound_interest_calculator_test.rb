require "test_helper"

class Tool::Presenter::CompoundInterestCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::CompoundInterestCalculator.new \
      annual_interest_rate: "8.0",
      initial_investment: "$100,000.00",
      monthly_contribution: "$1,000.00",
      years_to_grow: "10"
  end

  test "blankness" do
    assert Tool::Presenter::CompoundInterestCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "total value" do
    assert_equal 404_910.06, @tool.total_value
  end

  test "plot data" do
    first_plot_point = {
      year: 0,
      date: Date.today,
      contributed: 100_000.00,
      interest: 100_000.00,
      currentTotalValue: 100_000.00 }
    last_plot_point = {
      year: 10,
      date: Date.today + 10.years,
      contributed: 220_000.00,
      interest: 404_910.0586361822,
      currentTotalValue: 404_910.0586361822 }

    assert_equal first_plot_point, @tool.plot_data.first
    assert_equal last_plot_point, @tool.plot_data.last
  end
end
