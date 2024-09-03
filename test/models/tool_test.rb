# == Schema Information
#
# Table name: tools
#
#  id             :bigint           not null, primary key
#  category_slug  :string
#  content        :text
#  description    :text
#  icon           :string
#  intro          :text
#  meta_image_url :string
#  name           :string
#  slug           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "test_helper"

class ToolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
