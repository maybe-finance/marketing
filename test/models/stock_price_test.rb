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

require "test_helper"

class StockPriceTest < ActiveSupport::TestCase
  test "updating stock prices" do
    VCR.use_cassette "synth/known_ticker_prices" do
      assert_difference -> { StockPrice.count }, +StockPrice.distinct.pluck(:ticker).size do
        StockPrice.update_stock_prices
      end
    end
  end
end
