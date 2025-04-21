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

class Term < ApplicationRecord
  include MetaImage

  def self.random_sample(count, exclude:)
    where.not(id: exclude.id).order(Arel.sql("RANDOM()")).limit(count)
  end

  def to_param
    slug
  end

  private

  def create_meta_image
    super(title)
  end
end
