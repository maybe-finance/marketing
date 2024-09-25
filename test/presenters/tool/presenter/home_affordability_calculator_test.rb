require "test_helper"

class Tool::Presenter::HomeAffordabilityCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::HomeAffordabilityCalculator.new \
      loan_duration: "30",
      loan_interest_rate: "6.09",
      desired_home_price: "$300,000.00",
      down_payment: "$150,000.00",
      annual_pre_tax_income: "$120,000.00",
      monthly_debt_payments: "$1,500.00",
      hoa_plus_pmi: "$200.00"
  end

  test "blankness" do
    assert Tool::Presenter::HomeAffordabilityCalculator.new.blank?
    assert_not @tool.blank?
  end

  test "mortgage rates" do
    MortgageRate::Cache.any_instance.expects(:rate_30).returns("6.09")
    assert_equal "6.09", @tool.mortgage_rate_30

    MortgageRate::Cache.any_instance.expects(:rate_15).returns("5.15")
    assert_equal "5.15", @tool.mortgage_rate_15
  end

  test "affordable amount" do
    assert_equal 279_873.29, @tool.affordable_amount
  end

  test "plot data" do
    result = {
      segments: [
        { category: "Affordable", value: 279_873.29 },
        { category: "Good", value: 77_967.37 },
        { category: "Caution", value: 77_967.37 },
        { category: "Risky", value: 77_967.37 } ],
      desiredHomePrice: 300_000.00 }

    assert_equal result, @tool.plot_data
  end
end
