class Tool::Presenter::InsideTradingTracker < Tool::Presenter
  attribute :symbol, :string

  def blank?
    symbol.blank? || insider_trades.empty?
  end

  def company_name
    insider_data.dig(:meta, :name) || symbol&.upcase
  end

  def insider_trades
    return [] unless insider_data[:insider_transactions]&.any?

    insider_data[:insider_transactions].map do |trade|
      next unless trade[:description].present?

      is_purchase = trade[:description].include?("Purchase")
      is_sale = trade[:description].include?("Sale")
      next unless is_purchase || is_sale

      trade.merge(
        shares: is_purchase ? trade[:shares].to_i.abs : -trade[:shares].to_i.abs,
        value: is_purchase ? trade[:value].to_f.abs : -trade[:value].to_f.abs
      )
    end.compact
  end

  def total_value
    insider_trades.sum { |trade| trade[:value] }
  end

  def total_shares
    insider_trades.sum { |trade| trade[:shares] }
  end

  def top_trader
    insider_trades
      .group_by { |trade| trade[:full_name] }
      .transform_values { |trades| trades.sum { |t| t[:value].abs } }
      .max_by { |_, value| value }
      &.then { |name, value| { name: name, value: value } }
  end

  def largest_transaction
    insider_trades.max_by { |trade| trade[:value].abs }
  end

  def recent_trend
    last_month_trades = insider_trades
      .select { |t| Date.parse(t[:date_reported]) >= 30.days.ago }

    total_value = last_month_trades.sum { |t| t[:value] }
    total_volume = last_month_trades.sum { |t| t[:shares] }

    {
      value: total_value,
      volume: total_volume,
      count: last_month_trades.size
    }
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "inside-trading-tracker"
    end

    def insider_data
      @insider_data ||= begin
        response = Provider::TwelveData.new.insider_transactions(
          symbol: symbol
        )

        if response.success?
          response.transactions
        else
          { meta: {}, insider_transactions: [] }
        end
      end
    end
end
