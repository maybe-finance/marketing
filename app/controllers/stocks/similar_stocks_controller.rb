# This controller handles the retrieval and processing of similar stocks for a given stock ticker.
# It interacts with an external API (Synth Finance) to fetch related stock data and formats it for display.
class Stocks::SimilarStocksController < ApplicationController
  # GET /stocks/:stock_ticker/similar
  # Fetches and processes similar stocks data for the specified stock ticker.
  #
  # @param stock_ticker [String] The ticker symbol of the stock to find similar stocks for.
  # @return [void]
  def show
    if params[:stock_ticker].include?(":")
      symbol, mic_code = params[:stock_ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:stock_ticker], country_code: "US")
    end

    cache_key = "similar_stocks/v2/#{@stock.symbol}:#{@stock.mic_code}"

    cached_data = Rails.cache.read(cache_key)

    if cached_data.present?

      # Ensure we have an array of hashes
      if cached_data.is_a?(Array) && cached_data.all? { |item| item.is_a?(Hash) }
        @similar_stocks = cached_data.map { |stock| stock.transform_keys(&:to_sym) }

        respond_to do |format|
          format.html { render :show }
          format.json { render json: @similar_stocks }
        end
        return
      else
        Rails.logger.error "SimilarStocksController#show - Invalid cache format, deleting cache and fetching fresh data"
        Rails.cache.delete(cache_key)
      end
    end

    @similar_stocks = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }

      response = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}/related?mic_code=#{@stock.mic_code}", nil, headers)

      if response.success?
        data = JSON.parse(response.body)["data"]
        similar_stocks = []

        data["related_tickers"].each do |related_stock|
          break if similar_stocks.size == 6

          market_data = related_stock["market_data"]
          next if market_data.nil? || market_data.empty?
          next if market_data["open_today"].nil? || market_data["price_change"].nil? || market_data["percent_change"].nil?

          current_price = market_data["open_today"].to_f
          price_change = market_data["price_change"]
          percent_change = market_data["percent_change"]

          similar_stocks << {
            name: related_stock["name"],
            symbol: related_stock["ticker"],
            mic_code: related_stock["exchange"]["mic_code"],
            current_price: current_price,
            price_change: price_change,
            percent_change: percent_change
          }
        end

        similar_stocks
      else
        Rails.logger.error "SimilarStocksController#show - Failed to fetch data: #{response.status}"
        []
      end
    end

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @similar_stocks }
    end
  end
end
