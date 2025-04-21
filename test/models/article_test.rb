# == Schema Information
#
# Table name: articles
#
#  id             :integer          not null, primary key
#  title          :string
#  slug           :string
#  content        :text
#  publish_at     :datetime
#  author_name    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  meta_image_url :string
#

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
