# == Schema Information
#
# Table name: stock_prices
#
#  id         :integer          not null, primary key
#  ticker     :string
#  price      :float
#  month      :integer
#  year       :integer
#  date       :string
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
      StockPrice.distinct.pluck(:ticker).each do |ticker|
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

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at
      date
      id
      month
      price
      ticker
      updated_at
      year
    ]
  end
end
