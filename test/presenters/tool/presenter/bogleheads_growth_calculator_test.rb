require "test_helper"

class Tool::Presenter::BogleheadsGrowthCalculatorTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::BogleheadsGrowthCalculator.new \
      invested_amount: "$10,000.00",
      stock_market_ticker: "VTI",
      international_stock_market_ticker: "VXUS",
      bond_market_ticker: "BND",
      stock_market_percentage: "40",
      international_stock_market_percentage: "30",
      bond_market_percentage: "30"
  end

  test "blankness" do
    assert Tool::Presenter::BogleheadsGrowthCalculator.new.blank?
  end

  test "tool" do
    load Rails.root.join("db", "seeds", "seed_stocks.rb") # time consuming, which is why we use a single test

    first_plot_point = {
      yearMonth: "Jan 2011",
      year: 2011,
      month: 1,
      bondMarketFunds: 2_999.9999999999995,
      internationalStockFunds: 3_000.00,
      stockMarketFunds: 4_000.00,
      date: "2011-01-01",
      value: 10_000.00 }
    last_plot_point = {
      yearMonth: "Jun 2024",
      year: 2024,
      month: 6,
      bondMarketFunds: 2_704.0702016430173,
      internationalStockFunds: 3_620.088211708099,
      stockMarketFunds: 16_225.474796257167,
      date: "2024-06-01",
      value: 22_549.633209608284 }

    assert_not @tool.blank?
    assert_equal "125%", @tool.returns
    assert_equal 2.3, @tool.downside_deviation_value
    assert_equal "Moderate", @tool.risk_level
    assert_equal "$5,312.71 (24.64%)", @tool.drawdown_text
    assert_equal 22_549.63, @tool.final_value
    assert_equal "VTI (Vanguard)", @tool.legend_data[:stockMarketFunds][:name]
    assert_equal "VXUS (Vanguard)", @tool.legend_data[:internationalStockFunds][:name]
    assert_equal "BND (Vanguard)", @tool.legend_data[:bondMarketFunds][:name]
    assert_equal first_plot_point, @tool.plot_data.first
    assert_equal last_plot_point, @tool.plot_data.last
  end
end
