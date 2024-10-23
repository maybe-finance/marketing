# == Schema Information
#
# Table name: stocks
#
#  id             :bigint           not null, primary key
#  description    :text
#  legal_name     :string
#  links          :jsonb
#  meta_image_url :string
#  name           :string
#  search_vector  :tsvector
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stocks_on_search_vector  (search_vector) USING gin
#
require "test_helper"

class StockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
