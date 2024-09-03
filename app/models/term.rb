# == Schema Information
#
# Table name: terms
#
#  id                  :bigint           not null, primary key
#  content             :text
#  meta_image_url      :string
#  name                :string
#  slug                :string
#  title               :string
#  video_description   :text
#  video_duration      :string
#  video_thumbnail_url :string
#  video_title         :string
#  video_upload_date   :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  video_id            :string
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
