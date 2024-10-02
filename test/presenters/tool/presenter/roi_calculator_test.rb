require "test_helper"

class Tool::Presenter::RoiCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::RoiCalculator.new \
      amount_invested: "$50,500.00",
      amount_returned: "$60,000.00",
      investment_length: "5",
      investment_period: "years"
  end

  test "blankness" do
    assert Tool::Presenter::RoiCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "investment gain" do
    assert_equal 9_500.0, @tool.investment_gain
  end

  test "roi" do
    assert_equal 18.81, @tool.roi
  end

  test "annualized roi" do
    assert_equal 3.76, @tool.annualized_roi
  end

  test "roi sign" do
    assert_equal "+", @tool.roi_sign
    assert_nil Tool::Presenter::RoiCalculator.new(
      amount_invested: "$50,500.00",
      amount_returned: "$40,000.00",
      investment_length: "5",
      investment_period: "years"
    ).roi_sign
  end
end
