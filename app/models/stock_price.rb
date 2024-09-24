# == Schema Information
#
# Table name: stock_prices
#
#  id         :bigint           not null, primary key
#  date       :string
#  month      :integer
#  price      :float
#  ticker     :string
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stock_prices_on_ticker  (ticker)
#
class StockPrice < ApplicationRecord
  class << self
    def update_stock_prices(date = Date.yesterday)
      Stock.known_tickers.each do |ticker|
        response = Provider::Synth.new.stock_price(ticker: ticker, date: date)

        if response.success?
          StockPrice.find_or_create_by!(ticker: ticker, year: date.year, month: date.month) do |stock_price|
            stock_price.price = response.close
            stock_price.date = response.date
          end
        end
      end
    end
  end
end
