require "test_helper"

class Tool::Presenter::InflationCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::InflationCalculator.new \
      inflation_percentage: "3",
      initial_amount: "$100,000.00",
      years: "25"
  end

  test "blankness" do
    assert Tool::Presenter::InflationCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "future value" do
    assert_equal 209_377.79, @tool.future_value.round(2)
  end

  test "present value" do
    assert_equal 47_760.56, @tool.present_value.round(2)
  end

  test "inflation rate" do
    assert_equal 3.0, @tool.inflation_rate
  end

  test "amount increase" do
    assert_equal 109_377.79, @tool.amount_increase.round(2)
  end

  test "percentage increase" do
    assert_equal 109.38, @tool.percentage_increase.round(2)
  end

  test "amount loss" do
    assert_equal 52_239.44, @tool.amount_loss.round(2)
  end

  test "percentage loss" do
    assert_equal 52.24, @tool.percentage_loss.round(2)
  end
end
