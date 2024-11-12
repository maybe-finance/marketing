class Provider::Synth
  def initialize
    @api_key = ENV["SYNTH_API_KEY"]
  end

  def stock_price(ticker:, date:)
    response = fetch_stock_prices(ticker: ticker, start_date: date, end_date: date, limit: 1)

    if response.success? && (price = response.parsed_response["prices"].first) && (close = price["close"])
      StockPriceResponse.new \
        ticker: response.parsed_response["ticker"],
        close: close, date: price["date"],
        success?: true, raw_response: response
    else
      StockPriceResponse.new ticker: ticker, success?: false, raw_response: response
    end
  end

  def stock_prices(ticker:, start_date:, end_date:, interval: "day", limit: 100)
    response = fetch_stock_prices(ticker:, start_date:, end_date:, interval:, limit:)

    if response.success?
      StockPricesResponse.new \
        ticker: response.parsed_response["ticker"],
        prices: response.parsed_response["prices"],
        start_date: start_date.to_s, end_date: end_date.to_s,
        success?: true, raw_response: response
    else
      StockPricesResponse.new \
        ticker: ticker,
        start_date: start_date.to_s, end_date: end_date.to_s,
        success?: false, raw_response: response
    end
  end

  def exchange_rate(from_currency:, to_currency:)
    response = fetch_exchange_rate(from_currency: from_currency, to_currency: to_currency)

    if response.success? && (rate = response.parsed_response.dig("data", "rates", to_currency))
      ExchangeRateResponse.new(
        from_currency: from_currency,
        to_currency: to_currency,
        rate: rate,
        date: response.parsed_response.dig("data", "date"),
        time: response.parsed_response.dig("data", "time"),
        success?: true,
        raw_response: response
      )
    else
      ExchangeRateResponse.new(
        from_currency: from_currency,
        to_currency: to_currency,
        success?: false,
        raw_response: response
      )
    end
  end

  def exchange_rates(from_currency:, to_currency:, start_date:, end_date:)
    response = fetch_exchange_rates(
      from_currency: from_currency,
      to_currency: to_currency,
      start_date: start_date,
      end_date: end_date
    )

    if response.success?
      ExchangeRatesResponse.new(
        from_currency: from_currency,
        to_currency: to_currency,
        rates: parse_exchange_rates(response.parsed_response["data"], to_currency),
        success?: true,
        raw_response: response
      )
    else
      ExchangeRatesResponse.new(
        from_currency: from_currency,
        to_currency: to_currency,
        success?: false,
        raw_response: response
      )
    end
  end

  private
    BASE_URL = "https://api.synthfinance.com"

    attr_reader :api_key

    StockPriceResponse = Struct.new :ticker, :date, :close, :success?, :raw_response, keyword_init: true
    StockPricesResponse = Struct.new :ticker, :start_date, :end_date, :prices, :success?, :raw_response, keyword_init: true
    ExchangeRateResponse = Struct.new(
      :from_currency,
      :to_currency,
      :rate,
      :date,
      :time,
      :success?,
      :raw_response,
      keyword_init: true
    )
    ExchangeRatesResponse = Struct.new(
      :from_currency,
      :to_currency,
      :rates,
      :success?,
      :raw_response,
      keyword_init: true
    )

    def fetch_stock_prices(ticker:, start_date:, end_date:, interval: "day", limit: 100)
      HTTParty.get "#{BASE_URL}/tickers/#{ticker}/open-close",
        query: { start_date: start_date.to_s, end_date: end_date.to_s, interval: interval, limit: limit },
        headers: { "Authorization" => "Bearer #{api_key}", "X-Source" => "maybe_marketing", "X-Source-Type" => "api" }
    end

    def fetch_exchange_rate(from_currency:, to_currency:)
      HTTParty.get "#{BASE_URL}/rates/live",
        query: { from: from_currency, to: to_currency },
        headers: default_headers
    end

    def fetch_exchange_rates(from_currency:, to_currency:, start_date:, end_date:)
      HTTParty.get "#{BASE_URL}/rates/historical-range",
        query: {
          from: from_currency,
          to: to_currency,
          date_start: start_date.to_s,
          date_end: end_date.to_s
        },
        headers: default_headers
    end

    def default_headers
      {
        "Authorization" => "Bearer #{api_key}",
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }
    end

    def parse_exchange_rates(data, to_currency)
      data.map do |rate_data|
        {
          "date" => rate_data["date"],
          "rate" => rate_data["rates"][to_currency]
        }
      end
    end
end
