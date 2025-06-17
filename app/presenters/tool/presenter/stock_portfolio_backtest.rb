class Tool::Presenter::StockPortfolioBacktest < Tool::Presenter
  attribute :benchmark_stock, :string, default: "SPY"

  attribute :investment_amount, :tool_float, default: 10_000.0

  attribute :start_date, :date, default: -> { 1.year.ago }
  attribute :end_date, :date, default: -> { Date.today }

  attribute :stocks, :tool_array, type: :string, default: [ "AAPL", "MSFT", "GOOGL" ], max: 10
  attribute :stock_allocations, :tool_array, type: :percentage, default: [ 0.34, 0.33, 0.33 ], max: 10

  def blank?
    [ benchmark_stock, start_date ].all?(&:blank?)
  end

  def same_month?
    start_date.month == end_date.month && start_date.year == end_date.year
  end

  def portfolio_growth
    plot_data.last[:portfolio].round(0)
  end

  def benchmark_growth
    plot_data.last[:benchmark].round(0)
  end

  def legend_data
    {
      portfolio: {
        name: "Portfolio value",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      },
      benchmark: {
        name: "Benchmark value",
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      }
    }
  end

  def plot_data
    portfolio_trend_by_date
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "stock-portfolio-backtest"
    end

    def portfolio_trend_by_date
      @portfolio_trend_by_date ||= unique_dates.map do |date|
        {}.tap do |h|
          h[:yearMonth] = date.strftime("%b %Y")
          h[:year] = date.year.to_s
          h[:month] = date.month.to_s.rjust(2, "0")
          h[:date] = date.iso8601
          h[:benchmark] = benchmark_value_at(date)
          h[:portfolio] = portfolio_value_at(date)
        end
      end
    end

    def unique_dates
      @unique_dates ||= ohclv_data.flat_map do |data|
        data[:prices].map { |price| price["date"].to_date }
      end.uniq.sort
    end

    # `ohclv_data` -> [
    #   {
    #     ticker: "AAPL",
    #     prices: [{ "date": "2024-09-03", "open": 228.55, "close": 222.77, "high": 229, "low": 221.17, "volume": 49286866 }]
    #   }, ...
    # ]
    def ohclv_data
      @ohclv_data ||= begin
        tickers = stocks + [ benchmark_stock ]

        tickers.map do |ticker|
          response = Provider::Synth.new.stock_prices \
            ticker: ticker,
            start_date: start_date,
            end_date: end_date,
            interval: "month",
            limit: 500

          if response.success?
            { ticker: ticker, prices: response.prices }
          else
            { ticker: ticker, prices: [] }
          end
        end
      end
    end

    def benchmark_value_at(date)
      stock_shares(benchmark_stock, 1) * ohclv_at(date, stock: benchmark_stock)["close"]
    end

    def stock_shares(stock, allocation)
      initial_price = first_known_closing_price_for(stock)

      if initial_price.zero?
        0.0
      else
        investment_amount * allocation / initial_price
      end
    end

    def first_known_closing_price_for(stock)
      ohclv = ohclvs_for(stock).find { |price| price["close"].present? } || null_ohclv
      ohclv["close"]
    end

    def ohclv_at(date, stock:)
      ohclvs_for(stock).find { |price| price["date"].to_date == date } || null_ohclv(at: date)
    end

    def ohclvs_for(ticker)
      ohclv_data.find { |data| data[:ticker] == ticker }[:prices]
    end

    def null_ohclv(at: unique_dates.first)
      { "date" => at.iso8601, "open" => 0.0, "close" => 0.0, "high" => 0.0, "low" => 0.0, "volume" => 0.0 }
    end

    def portfolio_value_at(date)
      stocks.reduce(0.0) do |sum, stock|
        sum + portfolio_shares_by_ticker[stock] * ohclv_at(date, stock: stock)["close"]
      end
    end

    def portfolio_shares_by_ticker
      @portfolio_shares_by_ticker ||= stocks.zip(stock_allocations).map do |stock, allocation|
        [ stock, stock_shares(stock, allocation) ]
      end.to_h
    end
end
