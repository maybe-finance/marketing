class Tool::Presenter::ExchangeRateCalculator < Tool::Presenter
  attribute :amount, :tool_float, default: 1.0
  attribute :from_currency, :tool_string, default: "USD"
  attribute :to_currency, :tool_string, default: "EUR"

  def blank?
    amount.zero? || from_currency.blank? || to_currency.blank?
  end

  def converted_amount
    return 0.0 if blank?
    return amount if from_currency == to_currency

    rate = current_rate
    return 0.0 if rate.nil?

    amount * rate
  end

  def current_rate
    @current_rate ||= begin
      return 1.0 if from_currency == to_currency

      rate = fetch_current_rate
      Rails.logger.debug "Exchange Rate Rate: #{rate.inspect}"
      # Rails.logger.debug "Response rate: #{rate}"

      rate || 0.0
    rescue StandardError => e
      Rails.logger.error "Failed to fetch exchange rate: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      0.0
    end
  end

  def legend_data
    {
      rate: {
        name: "#{from_currency}/#{to_currency} Rate",
        fillClass: "fill-blue-500",
        strokeClass: "stroke-blue-500"
      }
    }
  end

  def plot_data
    end_date = Date.today
    start_date = end_date - 365.days

    Rails.logger.debug "Fetching exchange rates from #{start_date} to #{end_date}"

    response = Provider::Synth.new.exchange_rates(
      from_currency: from_currency,
      to_currency: to_currency,
      start_date: start_date,
      end_date: end_date
    )

    return [] unless response.success?

    Rails.logger.debug "Received rates: #{response.rates.first} to #{response.rates.last}"

    response.rates.map do |rate_data|
      date = Date.parse(rate_data["date"])
      {
        date: date,
        rate: rate_data["rate"],
        yearMonth: date.strftime("%B %Y")
      }
    end
  end

  def currency_options
    [
      [ "USD - US Dollar", "USD" ],
      [ "AUD - Australian Dollar", "AUD" ],
      [ "BRL - Brazilian Real", "BRL" ],
      [ "BTC - Bitcoin", "BTC" ],
      [ "CAD - Canadian Dollar", "CAD" ],
      [ "CHF - Swiss Franc", "CHF" ],
      [ "CNY - Chinese Yuan", "CNY" ],
      [ "ETH - Ethereum", "ETH" ],
      [ "EUR - Euro", "EUR" ],
      [ "GBP - British Pound", "GBP" ],
      [ "HKD - Hong Kong Dollar", "HKD" ],
      [ "INR - Indian Rupee", "INR" ],
      [ "JPY - Japanese Yen", "JPY" ],
      [ "KRW - South Korean Won", "KRW" ],
      [ "MXN - Mexican Peso", "MXN" ],
      [ "NZD - New Zealand Dollar", "NZD" ],
      [ "SEK - Swedish Krona", "SEK" ],
      [ "SGD - Singapore Dollar", "SGD" ],
      [ "TWD - Taiwan Dollar", "TWD" ],
      [ "ZAR - South African Rand", "ZAR" ]
    ]
  end

  def total_currencies
    currency_options.length
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "exchange-rate-calculator"
    end

    def fetch_current_rate
      response = synth_client.exchange_rate(
        from_currency: from_currency,
        to_currency: to_currency
      )

      response.success? ? response.rate : nil
    end

    def historical_rates
      start_date = 1.year.ago.to_date
      end_date = Date.today

      synth_client.exchange_rates(
        from_currency: from_currency,
        to_currency: to_currency,
        start_date: start_date,
        end_date: end_date
      ).rates
    end

    def synth_client
      @synth_client ||= Provider::Synth.new
    end
end
