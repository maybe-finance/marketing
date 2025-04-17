class CacheStockPageJob < ApplicationJob
  queue_as :default

  def perform(stock)
    Rails.logger.info "Starting cache job for #{stock.symbol}:#{stock.mic_code}"
    Rails.logger.info "Stock object: #{stock.inspect}"

    # Cache the main page data
    cache_stock_data(stock)

    # Cache individual components data
    cache_chart_data(stock)
    cache_info_data(stock)
    cache_statistics_data(stock)
    cache_price_performance_data(stock)
    cache_similar_stocks_data(stock)

    Rails.logger.info "Completed cache job for #{stock.symbol}:#{stock.mic_code}"
  end

  private

  def cache_stock_data(stock)
    cache_key = "stock_data/#{stock.symbol}:#{stock.mic_code}"
    Rails.logger.info "Writing to cache key: #{cache_key}"
    Rails.cache.write(
      cache_key,
      {
        symbol: stock.symbol,
        name: stock.name,
        mic_code: stock.mic_code,
        country_code: stock.country_code,
        exchange: stock.exchange
      },
      expires_in: 24.hours
    )
  end

  def cache_chart_data(stock)
    Rails.logger.info "Caching chart data for #{stock.symbol}:#{stock.mic_code}"
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    end_date = Date.today
    start_date = Date.today - 1.month

    response = Faraday.get(
      "https://api.synthfinance.com/tickers/#{stock.symbol}/open-close?mic_code=#{stock.mic_code}",
      {
        start_date: start_date.iso8601,
        end_date: end_date.iso8601,
        interval: "day",
        limit: 500
      },
      headers
    )

    if response.success?
      data = JSON.parse(response.body)
      valid_prices = data["prices"].reject { |p| p["no_data"] || p["close"].nil? || p["open"].nil? }

      if valid_prices.any?
        latest_price = valid_prices.last["close"].to_f
        first_price = valid_prices.first["open"].to_f
        price_change = (latest_price - first_price).round(2)
        price_change_percentage = ((price_change / first_price) * 100).round(2)
        currency = data["currency"] || "USD"
      else
        latest_price = price_change = price_change_percentage = 0
        currency = "USD"
      end

      chart_data = {
        latest_price: latest_price,
        price_change: price_change,
        price_change_percentage: price_change_percentage,
        currency: currency,
        prices: valid_prices
      }

      cache_key = "stock_chart/v3/#{stock.symbol}:#{stock.mic_code}/1M"
      Rails.logger.info "Writing to cache key: #{cache_key}"
      Rails.cache.write(
        cache_key,
        chart_data,
        expires_in: 24.hours
      )
      Rails.logger.info "Successfully cached chart data for #{stock.symbol}:#{stock.mic_code}"
    else
      Rails.logger.error "Failed to fetch chart data for #{stock.symbol}:#{stock.mic_code}: #{response.status}"
    end
  end

  def cache_info_data(stock)
    Rails.logger.info "Caching info data for #{stock.symbol}:#{stock.mic_code}"
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    response = Faraday.get("https://api.synthfinance.com/tickers/#{stock.symbol}?mic_code=#{stock.mic_code}", nil, headers)
    if response.success?
      data = JSON.parse(response.body)["data"]
      cache_key = "stock_info/v2/#{stock.symbol}:#{stock.mic_code}"
      Rails.logger.info "Writing to cache key: #{cache_key}"
      Rails.cache.write(
        cache_key,
        data,
        expires_in: 24.hours
      )
      Rails.logger.info "Successfully cached info data for #{stock.symbol}:#{stock.mic_code}"
    else
      Rails.logger.error "Failed to fetch info data for #{stock.symbol}:#{stock.mic_code}: #{response.status}"
    end
  end

  def cache_statistics_data(stock)
    Rails.logger.info "Caching statistics data for #{stock.symbol}:#{stock.mic_code}"
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    response = Faraday.get("https://api.synthfinance.com/tickers/#{stock.symbol}?mic_code=#{stock.mic_code}", nil, headers)
    if response.success?
      data = JSON.parse(response.body)["data"]
      market_data = data && data["market_data"] ? data["market_data"] : nil
      cache_key = "stock_statistics/v2/#{stock.symbol}:#{stock.mic_code}"
      Rails.logger.info "Writing to cache key: #{cache_key}"
      Rails.cache.write(
        cache_key,
        market_data,
        expires_in: 24.hours
      )
      Rails.logger.info "Successfully cached statistics data for #{stock.symbol}:#{stock.mic_code}"
    else
      Rails.logger.error "Failed to fetch statistics data for #{stock.symbol}:#{stock.mic_code}: #{response.status}"
    end
  end

  def cache_price_performance_data(stock)
    Rails.logger.info "Caching price performance data for #{stock.symbol}:#{stock.mic_code}"
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    # Fetch real-time data
    response = Faraday.get("https://api.synthfinance.com/tickers/#{stock.symbol}/real-time?mic_code=#{stock.mic_code}", nil, headers)
    if response.success?
      real_time_data = JSON.parse(response.body)["data"]
      performance_data = {
        low: real_time_data["low"],
        high: real_time_data["high"],
        current: real_time_data["fair_market_value"]
      }

      cache_key = "price_performance/v2/#{stock.symbol}:#{stock.mic_code}/24h"
      Rails.logger.info "Writing to cache key: #{cache_key}"
      Rails.cache.write(
        cache_key,
        performance_data,
        expires_in: 24.hours
      )
      Rails.logger.info "Successfully cached price performance data for #{stock.symbol}:#{stock.mic_code}"
    else
      Rails.logger.error "Failed to fetch price performance data for #{stock.symbol}:#{stock.mic_code}: #{response.status}"
    end
  end

  def cache_similar_stocks_data(stock)
    Rails.logger.info "Caching similar stocks data for #{stock.symbol}:#{stock.mic_code}"
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    response = Faraday.get("https://api.synthfinance.com/tickers/#{stock.symbol}/related?mic_code=#{stock.mic_code}", nil, headers)
    if response.success?
      data = JSON.parse(response.body)["data"]
      similar_stocks = []

      if data && data["related_tickers"]
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
      end

      cache_key = "similar_stocks/v2/#{stock.symbol}:#{stock.mic_code}"
      Rails.logger.info "Writing to cache key: #{cache_key}"
      Rails.logger.info "Data to be cached: #{similar_stocks.inspect}"
      Rails.cache.write(
        cache_key,
        similar_stocks,
        expires_in: 24.hours
      )
      # Verify the cache write
      cached_data = Rails.cache.read(cache_key)
      Rails.logger.info "Cache verification - Read back from cache: #{cached_data.inspect}"
      Rails.logger.info "Successfully cached similar stocks data for #{stock.symbol}:#{stock.mic_code}"
    else
      Rails.logger.error "Failed to fetch similar stocks data for #{stock.symbol}:#{stock.mic_code}: #{response.status}"
    end
  end
end
