class ScheduleStockCacheJob < ApplicationJob
  queue_as :default

  def perform
    # Get all stocks that need caching
    stocks = Stock.where(kind: "stock").where.not(mic_code: nil)
    total_stocks = stocks.count
    stocks_per_hour = (total_stocks / 24.0).ceil

    # Schedule jobs for each hour
    24.times do |hour|
      start_idx = hour * stocks_per_hour
      end_idx = [ start_idx + stocks_per_hour, total_stocks ].min

      # Get the stocks for this hour
      hour_stocks = stocks.offset(start_idx).limit(stocks_per_hour)

      # Calculate delay between each job in seconds
      delay_between_jobs = 3600.0 / hour_stocks.count # 3600 seconds in an hour

      hour_stocks.each_with_index do |stock, index|
        # Calculate the exact time to run this job within the hour
        run_at = Time.current.beginning_of_hour + hour.hours + (index * delay_between_jobs).seconds

        CacheStockPageJob.set(wait_until: run_at).perform_later(stock)
      end
    end
  end
end
