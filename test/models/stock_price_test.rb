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
require "test_helper"

class StockPriceTest < ActiveSupport::TestCase
  test "updating stock prices" do
    VCR.use_cassette "synth/known_ticker_prices" do
      assert_difference -> { StockPrice.count }, +Stock.known_tickers.size do
        StockPrice.update_stock_prices
      end
    end
  end
end
