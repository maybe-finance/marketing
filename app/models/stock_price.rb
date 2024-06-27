class StockPrice < ApplicationRecord
    def self.get_ticker_url(ticker)
      "https://api.synthfinance.com/tickers/#{ticker}/open-close"
    end

    def self.update_stock_prices
      token = ENV["SYNTH_API_KEY"]

      return unless !token.blank?

      stock_date = Date.yesterday

      query = {
        start_date: stock_date.to_s,
        end_date: stock_date.to_s
      }

      tickers = StockPrice.distinct.pluck(:ticker)

      begin
        tickers.each do |ticker|
          response = HTTParty.get(
            get_ticker_url(ticker),
            query: query,
            headers: {
              "Authorization" => "Bearer #{token}"
            }
          )

          if response.success?
            prices = response.parsed_response["prices"]

            price_data = prices.first

            if price_data && price_data.has_key?("close")
              stock_data = StockPrice.find_or_create_by(ticker: ticker, year: stock_date.year)
              stock_data.update(price: price_data["close"])
            else
              puts "No closing price data found for ticker: #{ticker}"
            end
          else
            puts "Failed to update stock price for ticker: #{ticker}"
          end
          puts "Updated stock price for: #{ticker}"
        end
      rescue StandardError => e
        puts "Error occurred while updating stock prices: #{e.message}"
      end
    end

    def self.fetch_stock_data
      redis = Redis.new
      cache_key = "stock_prices"

      cached_response = redis.get(cache_key)
      return JSON.parse(cached_response) if cached_response

      stock_prices = StockPrice.all
      grouped_data = stock_prices.group_by(&:ticker)

      output = {}

      grouped_data.each do |ticker, year_prices|
        annual_stock_prices = year_prices.map do |record|
          { year: record.year, price: record.price }
        end

        output[ticker] = annual_stock_prices
      end

      redis.set(cache_key, JSON.generate(output))
      output
    end
end
