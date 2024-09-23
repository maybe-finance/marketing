class Tool::Presenter::StockPortfolioBacktest < Tool::Presenter
  attribute :benchmark_stock, :string

  attribute :investment_amount, :tool_float, default: 10_000.0

  attribute :start_date, :date
  attribute :end_date, :date, default: -> { Date.current }

  attribute :stocks, :tool_array, type: :string, default: []
  attribute :stock_allocations, :tool_array, type: :percentage, default: []

  def blank?
    [ benchmark_stock, start_date ].all?(&:blank?) || start_date.month == end_date.month
  end

  def searchable_stocks
    @searchable_stocks ||= Stock.select(:name, :symbol).map do |stock|
      { name: stock.name, value: stock.symbol }
    end
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

    def unique_dates
      @unique_dates ||= ohclv_data.flat_map { |data| data[:prices].map { |price| price["date"].to_date } }.uniq.sort
    end

    def ohclv_data
      @ohclv_data ||= begin
        tickers = stocks + [ benchmark_stock ]

        tickers.map do |ticker|
          response = Provider::Synth.new.stock_prices(
            ticker: ticker,
            start_date: start_date,
            end_date: end_date,
            interval: "month",
            limit: 500
          )

          { ticker: response.ticker, prices: response.prices }
        end
      end
    end

    def portfolio_trend_by_date
      @portfolio_trend_by_date ||= unique_dates.map do |date|
        {}.tap do |h|
          h[:yearMonth] = date.strftime("%b %Y")
          h[:year] = date.year
          h[:month] = date.month
          h[:date] = date
          h[:benchmark] = benchmark_value_at(date)
          h[:portfolio] = portfolio_value_at(date)
        end
      end
    end

    def benchmark_value_at(date)
      benchmark_shares * ohlc_at(date, stock: benchmark_stock)["close"]
    end

    def benchmark_shares
      investment_amount / initial_stock_price(benchmark_stock)
    end

    def initial_stock_price(stock)
      ohclv_data.find { |data| data[:ticker] == stock }[:prices].first["close"]
    end

    def ohlc_at(date, stock:)
      all_ohlc = ohclv_data.find { |data| data[:ticker] == stock }[:prices]
      all_ohlc.find { |price| price["date"].to_date == date }
    end

    def portfolio_value_at(date)
      stocks.reduce(0.0) do |sum, stock|
        sum + portfolio_shares_by_ticker[stock] * ohlc_at(date, stock: stock)["close"]
      end
    end

    def portfolio_shares_by_ticker
      @portfolio_shares_by_ticker ||= stocks.zip(stock_allocations).map do |stock, allocation|
        [ stock, investment_amount * allocation / initial_stock_price(stock) ]
      end.to_h
    end
end
