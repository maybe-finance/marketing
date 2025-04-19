# This controller handles requests for stock information.
# It fetches stock data from the Synth Finance API for a given stock ticker.
class Stocks::InfoController < ApplicationController
  # GET /stocks/:stock_ticker/info
  # Retrieves and displays information for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock (passed in the URL)
  # @return [Object] Sets @stock and @stock_info instance variables for use in the view
  def show
    if params[:stock_ticker].include?(":")
      symbol, mic_code = params[:stock_ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:stock_ticker], country_code: "US")
    end

    cache_key = "stock_info/v2/#{@stock.symbol}:#{@stock.mic_code}"

    if cached = Rails.cache.read(cache_key)
      @stock_info = cached
      respond_to do |format|
        format.html { render :show }
        format.json { render json: @stock_info }
      end
      return
    end

    @stock_info = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }

      response = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}?mic_code=#{@stock.mic_code}", nil, headers)
      JSON.parse(response.body)["data"]
    end

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @stock_info }
    end
  end
end
