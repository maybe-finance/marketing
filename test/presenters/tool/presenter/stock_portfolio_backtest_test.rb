require "test_helper"

class Tool::Presenter::StockPortfolioBacktestTest < ActiveSupport::TestCase
  setup do
    @tool = Tool::Presenter::StockPortfolioBacktest.new \
      benchmark_stock: "IXUS",
      investment_amount: "$100,000.00",
      start_date: "2020-01-07",
      end_date: "2024-09-29",
      stocks: %w[ AGG SCHB SCHZ ],
      stock_allocations: [ 33, 33, 34 ]

    VCR.insert_cassette "synth/stock_portfolio_backtest"
  end

  teardown do
    VCR.eject_cassette
  end

  test "blankness" do
    assert Tool::Presenter::StockPortfolioBacktest.new.blank?
    assert_not @tool.blank?
  end

  test "portfolio growth" do
    assert_equal 120_098, @tool.portfolio_growth
  end

  test "benchmark growth" do
    assert_equal 131_037, @tool.benchmark_growth
  end

  test "plot data" do
    first_plot_point = {
      yearMonth: "Feb 2020",
      year: "2020",
      month: "02",
      date: "2020-02-01",
      portfolio: 100_000,
      benchmark: 100_000 }
    last_plot_point = {
      yearMonth: "Sep 2024",
      year: "2024",
      month: "09",
      date: "2024-09-01",
      portfolio: 120_098.4412550996,
      benchmark: 131_036.95730175817 }

    assert_equal first_plot_point, @tool.plot_data.first
    assert_equal last_plot_point, @tool.plot_data.last
  end

  test "with an unknown stock" do
    VCR.use_cassette "synth/stock_portfolio_backtest_unknown_stock" do
      tool = Tool::Presenter::StockPortfolioBacktest.new \
        benchmark_stock: "IXUS",
        investment_amount: "$100,000.00",
        start_date: "2024-08-07",
        end_date: "2024-09-29",
        stocks: %w[ AACIU AACIW ],
        stock_allocations: [ 50, 50 ]

      assert_not_nil tool.plot_data
      assert_not_nil tool.portfolio_growth
      assert_not_nil tool.benchmark_growth
    end
  end

  test "too many stocks" do
    assert_raises ArgumentError do
      Tool::Presenter::StockPortfolioBacktest.new(stocks: %w[ AGG SCHB SCHZ VTI VOO VEA VWO VTV VUG VIG VYM ]).stocks
    end

    assert_raises ArgumentError do
      Tool::Presenter::StockPortfolioBacktest.new(stock_allocations: [ 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10 ]).stock_allocations
    end
  end
end
