# == Schema Information
#
# Table name: stocks
#
#  id             :bigint           not null, primary key
#  country_code   :string
#  description    :text
#  exchange       :string
#  industry       :string
#  kind           :string
#  legal_name     :string
#  links          :jsonb
#  meta_image_url :string
#  mic_code       :string
#  name           :string
#  search_vector  :tsvector
#  sector         :string
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stocks_on_country_code         (country_code)
#  index_stocks_on_exchange             (exchange)
#  index_stocks_on_kind                 (kind)
#  index_stocks_on_mic_code             (mic_code)
#  index_stocks_on_search_vector        (search_vector) USING gin
#  index_stocks_on_symbol_and_mic_code  (symbol,mic_code) UNIQUE
#
require "test_helper"

class StockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
