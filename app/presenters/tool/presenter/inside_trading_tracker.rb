class Tool::Presenter::InsideTradingTracker < Tool::Presenter
  attribute :symbol, :string
  attribute :action_name, :string
  attribute :filter, :string

  def blank?
    insider_trades.empty?
  end

  def company_name
    return "Recent Insider Trading Activity" if symbol.blank?
    insider_data.dig(:meta, :name) || symbol&.upcase
  end

  def insider_trades(filter = nil)
    if symbol.present?
      return [] unless insider_data[:trades]&.any?
      format_trades(insider_data[:trades])
    else
      case filter
      when "top-owners"
        fetch_filtered_trades(ten_percent_owner: true, min_value: 100_000, sort: "value")
      when "biggest-trades"
        fetch_filtered_trades(min_value: 1_000_000, sort: "value")
      when "top-officers"
        fetch_filtered_trades(officer: true, min_value: 100_000, sort: "value")
      else
        recent_insider_trades
      end
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
      @insider_data ||= Rails.cache.fetch("insider_trades/#{symbol}/#{180.days.ago.to_date}/#{Date.today}/250", expires_in: 6.hours) do
        response = Provider::Synth.new.insider_trades(
          ticker: symbol,
          start_date: 180.days.ago,
          end_date: Date.today,
          limit: 250
        )

        if response.success?
          { trades: response.trades }
        else
          { trades: [] }
        end
      end
    end

    def recent_insider_trades
      Rails.cache.fetch("recent_insider_trades/#{Date.today}", expires_in: 6.hours) do
        response = Provider::Synth.new.recent_insider_trades(limit: 250)
        return [] unless response[:trades]&.any?
        format_trades(response[:trades])
      end
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
          company: trade.dig("company", "name") || trade["company_name"] || trade["ticker"],
          company_description: trade.dig("company", "description"),
          company_industry: trade.dig("company", "industry"),
          company_sector: trade.dig("company", "sector"),
          company_employees: trade.dig("company", "total_employees"),
          ticker: trade["ticker"],
          position: trade["position"],
          exchange: trade.dig("exchange", "acronym"),
          exchange_country: trade.dig("exchange", "country_code"),
          footnotes: trade["footnotes"],
          transaction_type: transaction_type
        }
      end.compact
    end

    def fetch_filtered_trades(filters = {})
      cache_key = "filtered_insider_trades/#{filters.to_json}/#{90.days.ago.to_date}/#{Date.today}"

      Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        Rails.logger.warn "Fetching filtered trades with filters: #{filters}"
        response = Provider::Synth.new.recent_insider_trades(
          start_date: 90.days.ago,
          end_date: Date.today,
          limit: 250,
          **filters
        )

        return [] unless response.success? && response.trades&.any?
        format_trades(response.trades)
      end
    end
end
