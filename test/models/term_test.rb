# == Schema Information
#
# Table name: terms
#
#  id                  :integer          not null, primary key
#  name                :string
#  title               :string
#  content             :text
#  slug                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  video_id            :string
#  video_title         :string
#  video_description   :text
#  video_thumbnail_url :string
#  video_upload_date   :date
#  video_duration      :string
#  meta_image_url      :string
#

require "test_helper"

class TermTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
