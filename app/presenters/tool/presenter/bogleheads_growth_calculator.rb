class Tool::Presenter::BogleheadsGrowthCalculator < Tool::Presenter
  attribute :invested_amount, :tool_float, default: 10000.0

  attribute :stock_market_percentage, :tool_percentage, default: 40.0
  attribute :international_stock_market_percentage, :tool_percentage, default: 30.0
  attribute :bond_market_percentage, :tool_percentage, default: 30.0

  attribute :stock_market_ticker, :tool_enum, enum: Stock.known_tickers, default: "VTI"
  attribute :international_stock_market_ticker, :tool_enum, enum: Stock.known_tickers, default: "VXUS"
  attribute :bond_market_ticker, :tool_enum, enum: Stock.known_tickers, default: "BND"

  def blank?
    invested_amount.zero?
  end

  def returns
    "#{((profit_or_loss / invested_amount) * 100).floor}%"
  end

  def downside_deviation_value
    downside_deviation.value
  end

  def risk_level
    downside_deviation.risk_level
  end

  def drawdown_text
    max_drawdown_value, max_drawdown_percentage = drawdown_values
    "#{number_to_currency(max_drawdown_value)} (#{max_drawdown_percentage.round(2)}%)"
  end

  def final_value
    monthly_portfolio_breakdowns.last[:value].round(2)
  end

  def legend_data
    {
      value: {
        name: "Portfolio value",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      },
      stockMarketFunds: {
        name: stock_market_position.ticker_name,
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      },
      internationalStockFunds: {
        name: international_stock_market_position.ticker_name,
        fillClass: "fill-cyan-400",
        strokeClass: "stroke-cyan-400"
      },
      bondMarketFunds: {
        name: bond_market_position.ticker_name,
        fillClass: "fill-violet-500",
        strokeClass: "stroke-violet-500"
      }
    }
  end

  def plot_data
    monthly_portfolio_breakdowns
  end

  private
    delegate :number_to_currency, to: "ApplicationController.helpers"

    def active_record
      @active_record ||= Tool.find_by! slug: "bogleheads-growth-calculator"
    end

    def monthly_portfolio_breakdowns
      @monthly_portfolio_breakdowns ||= begin
        earliest_common_date.year.upto(latest_common_date.year).flat_map do |year|
          first_known_month_for(year).upto(last_known_month_for(year)).map do |month|
            bond_market_value = bond_market_position.value_at(year: year, month: month, purchase_date: earliest_common_date)
            stock_market_value = stock_market_position.value_at(year: year, month: month, purchase_date: earliest_common_date)
            intl_stock_market_value = international_stock_market_position.value_at(year: year, month: month, purchase_date: earliest_common_date)

            value = bond_market_value + stock_market_value + intl_stock_market_value

            if value.finite?
              {}.tap do |h|
                h[:yearMonth] = "#{Date::ABBR_MONTHNAMES[month]} #{year}"
                h[:year] = year
                h[:month] = month
                h[:bondMarketFunds] = bond_market_value
                h[:stockMarketFunds] = stock_market_value
                h[:internationalStockFunds] = intl_stock_market_value
                h[:date] = "#{year}-#{month.to_s.rjust(2, "0")}-01"
                h[:value] = value
              end
            end
          end.compact
        end
      end
    end

    def earliest_common_date
      [
        bond_market_position.earliest_known_date,
        international_stock_market_position.earliest_known_date,
        stock_market_position.earliest_known_date
      ].max
    end

    def latest_common_date
      [
        bond_market_position.latest_known_date,
        international_stock_market_position.latest_known_date,
        stock_market_position.latest_known_date
      ].min
    end

    def first_known_month_for(year)
      if year == earliest_common_date.year
        earliest_common_date.month
      else
        1
      end
    end

    def last_known_month_for(year)
      if year == latest_common_date.year
        latest_common_date.month
      else
        12
      end
    end

    def bond_market_position
      @bond_market_position ||= Tool::Bogleheads::Position.new \
        ticker: bond_market_ticker,
        allocation: invested_amount * bond_market_percentage
    end

    def international_stock_market_position
      @international_stock_market_position ||= Tool::Bogleheads::Position.new \
        ticker: international_stock_market_ticker,
        allocation: invested_amount * international_stock_market_percentage
    end

    def stock_market_position
      @stock_market_position ||= Tool::Bogleheads::Position.new \
        ticker: stock_market_ticker,
        allocation: invested_amount * stock_market_percentage
    end

    def downside_deviation
      @downside_deviation ||= Tool::Bogleheads::DownsideDeviation.new(self)
    end

    def profit_or_loss
      final_value - invested_amount
    end

    def drawdown_values
      peak_value = 0
      max_drawdown_value = 0
      max_drawdown_percentage = 0

      monthly_portfolio_breakdowns.each do |month|
        peak_value = month[:value] if month[:value] > peak_value

        if peak_value - month[:value] > max_drawdown_value
          max_drawdown_value = peak_value - month[:value]
          max_drawdown_percentage = (max_drawdown_value / peak_value) * 100
        end
      end

      [ max_drawdown_value, max_drawdown_percentage ]
    end
end
