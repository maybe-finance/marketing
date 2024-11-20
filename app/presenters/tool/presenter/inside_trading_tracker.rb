class Tool::Presenter::InsideTradingTracker < Tool::Presenter
  attribute :symbol, :string

  def blank?
    insider_trades.empty?
  end

  def company_name
    return "Recent Insider Trading Activity" if symbol.blank?
    insider_data.dig(:meta, :name) || symbol&.upcase
  end

  def insider_trades
    if symbol.blank?
      recent_insider_trades
    else
      return [] unless insider_data[:trades]&.any?
      format_trades(insider_data[:trades])
    end
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
        response = Provider::Synth.new.insider_trades(
          ticker: symbol,
          start_date: 90.days.ago,
          end_date: Date.today,
          limit: 100
        )

        if response.success?
          { trades: response.trades }
        else
          { trades: [] }
        end
      end
    end

    def recent_insider_trades
      response = Provider::Synth.new.recent_insider_trades(limit: 50)
      return [] unless response[:trades]&.any?
      format_trades(response[:trades])
    end

    def format_trades(trades)
      trades.map do |trade|
        next unless trade["transaction_type"].present?

        transaction_type = trade["transaction_type"]
        is_positive = [ "Purchase", "Grant", "Exercise/Conversion" ].include?(transaction_type)
        is_negative = [ "Sale", "Sale to Issuer", "Payment of Exercise Price" ].include?(transaction_type)
        next unless is_positive || is_negative || transaction_type == "Discretionary Transaction"

        shares = trade["shares"].to_i.abs
        value = trade["value"].to_f.abs

        {
          full_name: trade["full_name"],
          title: trade["position"],
          date_reported: trade["transaction_date"],
          description: trade["formatted_transaction_code"],
          shares: is_positive ? shares : -shares,
          value: is_positive ? value : -value,
          price: trade["price"],
          roles: trade["formatted_roles"],
          ownership_type: trade["formatted_ownership_type"],
          post_transaction_shares: trade["post_transaction_shares"],
          filing_link: trade["filing_link"],
          summary: trade["summary"],
          company: trade["company_name"] || trade["ticker"],
          ticker: trade["ticker"],
          position: trade["position"],
          exchange: trade.dig("exchange", "acronym"),
          exchange_country: trade.dig("exchange", "country_code"),
          footnotes: trade["footnotes"],
          transaction_type: transaction_type
        }
      end.compact
    end
end
