# == Schema Information
#
# Table name: tools
#
#  id             :integer          not null, primary key
#  name           :string
#  slug           :string
#  intro          :text
#  description    :text
#  content        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_slug  :string
#  icon           :string
#  meta_image_url :string
#

require "test_helper"

class ToolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
