class Provider::TwelveData
  def initialize
    @api_key = ENV.fetch("TWELVE_DATA_API_KEY")
  end

  def insider_transactions(symbol:)
    response = fetch_insider_transactions(symbol:)

    if response.success?
      InsiderTransactionsResponse.new(
        symbol: symbol,
        transactions: JSON.parse(response.body, symbolize_names: true),
        success?: true,
        raw_response: response
      )
    else
      InsiderTransactionsResponse.new(
        symbol: symbol,
        success?: false,
        raw_response: response
      )
    end
  end

  private
    BASE_URL = "https://api.twelvedata.com"

    attr_reader :api_key

    InsiderTransactionsResponse = Struct.new(
      :symbol,
      :transactions,
      :success?,
      :raw_response,
      keyword_init: true
    )

    def fetch_insider_transactions(symbol:)
      HTTParty.get "#{BASE_URL}/insider_transactions",
        query: {
          symbol: symbol,
          apikey: api_key
        },
        headers: default_headers
    end

    def default_headers
      {
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }
    end
end
