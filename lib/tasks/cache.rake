namespace :cache do
  desc "Schedule caching of all stock pages over 24 hours"
  task schedule_stock_pages: :environment do
    ScheduleStockCacheJob.perform_later
  end
end
