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
    fetch_current_rate
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
    cache_key = "exchange_rates/v2/#{from_currency}/#{to_currency}/#{start_date}/#{end_date}"

    Rails.logger.debug "Fetching exchange rates from #{start_date} to #{end_date}."

    response = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      Rails.logger.debug "Cache miss for #{cache_key}. Fetching from Synth API."
      api_response = synth_client.exchange_rates(
        from_currency: from_currency,
        to_currency: to_currency,
        start_date: start_date,
        end_date: end_date
      )

      # Only return the response for caching if it was successful
      api_response if api_response&.success?
    end

    # If response is nil (cache miss failed, or cached nil) or not successful, return empty
    return [] unless response&.success?

    Rails.logger.debug "Received rates (from cache or API): #{response.rates&.first} to #{response.rates&.last}"

    (response.rates || []).map do |rate_data|
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
      return 1.0 if from_currency == to_currency

      cache_key = "exchange_rate/v2/#{from_currency}/#{to_currency}"
      Rails.logger.debug "Fetching current exchange rate for #{from_currency}/#{to_currency}."

      # Fetch from cache or execute the block if missed
      response = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
        Rails.logger.debug "Cache miss for #{cache_key}. Fetching from Synth API."
        api_response = synth_client.exchange_rate(
          from_currency: from_currency,
          to_currency: to_currency
        )

        # Only return the response for caching if it was successful
        api_response if api_response&.success?
      end

      Rails.logger.debug "Exchange Rate Response (from cache or API): #{response.inspect}"

      # Return the rate if the response (cached or fresh) is successful, otherwise nil
      response&.success? ? response.rate : nil
    rescue StandardError => e
      Rails.logger.error "Failed to fetch exchange rate: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end

    def synth_client
      @synth_client ||= Provider::Synth.new
    end
end
