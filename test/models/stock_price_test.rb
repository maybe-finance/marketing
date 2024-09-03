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
require "test_helper"

class StockPriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
