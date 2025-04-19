class Stocks::StockEarningsController < ApplicationController
  def show
    if params[:stock_ticker].include?(":")
      symbol, mic_code = params[:stock_ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:stock_ticker], country_code: "US")
    end

    if cached = Rails.cache.read("stock_earnings/v2/#{@stock.symbol}:#{@stock.mic_code}")
      @earnings = cached
      render :show
      return
    end

    @earnings = Rails.cache.fetch("stock_earnings/v2/#{@stock.symbol}:#{@stock.mic_code}", expires_in: 1.hour) do
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }

      response = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}/earnings?mic_code=#{@stock.mic_code}", nil, headers)

      if response.success?
        JSON.parse(response.body)["data"]
      else
        []
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @earnings }
    end
  end
end
