require "test_helper"

class Tool::Presenter::StockPortfolioBacktestTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::StockPortfolioBacktest.new \
      benchmark_stock: "SCHZ",
      investment_amount: "$10,000.00",
      start_date: "2020-01-10",
      end_date: "2024-09-29",
      stocks: %w[ IXUS ],
      stock_allocations: [ 100 ]

    VCR.insert_cassette "synth/stock_portfolio_backtest"
  end

  teardown do
    VCR.eject_cassette
  end

  test "blankness" do
    assert Tool::Presenter::StockPortfolioBacktest.new.blank?
    assert_not @tool.blank?
  end

  test "searchable stocks" do
    assert_equal Stock.count, @tool.searchable_stocks.size
  end

  test "portfolio growth" do
    assert_equal 13_104, @tool.portfolio_growth
  end

  test "benchmark growth" do
    assert_equal 8_628, @tool.benchmark_growth
  end

  test "plot data" do
    first_plot_point = {
      yearMonth: "Feb 2020",
      year: "2020",
      month: "02",
      date: "2020-02-01",
      portfolio: 10_000,
      benchmark: 10_000 }
    last_plot_point = {
      yearMonth: "Sep 2024",
      year: "2024",
      month: "09",
      date: "2024-09-01",
      portfolio: 13_103.695730175818,
      benchmark: 8_628.374705562603 }

    assert_equal first_plot_point, @tool.plot_data.first
    assert_equal last_plot_point, @tool.plot_data.last
  end
end
