namespace :data do
  desc "This updates current year's stock price for supported tickers!"
  task update_stock_prices: :environment do
    StockPrice.update_stock_prices
  end
end
