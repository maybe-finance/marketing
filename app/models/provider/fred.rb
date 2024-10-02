class Provider::Fred
  def initialize
    @api_key = ENV["FRED_API_KEY"]
  end

  def mortgage_rate_30
    build_mortgage_rate_response "MORTGAGE30US"
  end

  def mortgage_rate_15
    build_mortgage_rate_response "MORTGAGE15US"
  end

  private
    BASE_URL = "https://api.stlouisfed.org/fred"

    attr_reader :api_key

    MortgageRateResponse = Struct.new :series_id, :value, :success?, :raw_response, keyword_init: true

    def build_mortgage_rate_response(series_id)
      response = fetch_mortgage_rate(series_id)

      if response.success? && (value = response.parsed_response["observations"].first&.try(:[], "value"))
        MortgageRateResponse.new series_id: series_id, value: value, success?: true, raw_response: response
      else
        MortgageRateResponse.new success?: false, raw_response: response
      end
    end

    def fetch_mortgage_rate(series_id)
      HTTParty.get "#{BASE_URL}/series/observations", query: {
        api_key: api_key, series_id: series_id,
        file_type: "json", limit: 1,
        sort_order: "desc", frequency: "w" }
    end
end
