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
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "test_helper"

class StockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
