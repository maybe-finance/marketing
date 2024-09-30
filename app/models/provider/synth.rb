class Provider::Synth
  def initialize
    @api_key = ENV["SYNTH_API_KEY"]
  end

  def stock_price(ticker:, date:)
    response = fetch_stock_prices(ticker: ticker, start_date: date, end_date: date)

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

  private
    BASE_URL = "https://api.synthfinance.com"

    attr_reader :api_key

    StockPriceResponse = Struct.new :ticker, :date, :close, :success?, :raw_response, keyword_init: true
    StockPricesResponse = Struct.new :ticker, :start_date, :end_date, :prices, :success?, :raw_response, keyword_init: true

    def fetch_stock_prices(ticker:, start_date:, end_date:, interval: "day", limit: 100)
      HTTParty.get "#{BASE_URL}/tickers/#{ticker}/open-close",
        query: { start_date: start_date.to_s, end_date: end_date.to_s, interval: interval, limit: limit },
        headers: { "Authorization" => "Bearer #{api_key}", "X-Source" => "maybe_marketing", "X-Source-Type" => "api" }
    end
end
