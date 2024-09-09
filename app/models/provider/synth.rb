class Provider::Synth
  def initialize
    @api_key = ENV["SYNTH_API_KEY"]
  end

  def fetch_stock_price(ticker:, date:)
    response = fetch_raw_stock_prices(ticker: ticker, start_date: date, end_date: date)

    if response.success? && (price = response.parsed_response["prices"].first) && (close = price["close"])
      StockPriceResponse.new \
        ticker: response.parsed_response["ticker"],
        close: close, date: price["date"],
        success?: true, raw_response: response
    else
      StockPriceResponse.new success?: false, raw_response: response
    end
  end

  private
    attr_reader :api_key

    StockPriceResponse = Struct.new :ticker, :date, :close, :success?, :raw_response, keyword_init: true

    def base_url
      "https://api.synthfinance.com"
    end

    def fetch_raw_stock_prices(ticker:, start_date:, end_date:)
      HTTParty.get "#{base_url}/tickers/#{ticker}/open-close",
        query: { start_date: start_date.to_s, end_date: end_date.to_s },
        headers: { "Authorization" => "Bearer #{api_key}", "X-Source" => "maybe_marketing", "X-Source-Type" => "api" }
    end
end
