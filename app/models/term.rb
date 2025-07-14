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
  has_one :authorship, as: :authorable, dependent: :destroy
  has_one :author, through: :authorship

  include MetaImage

  def self.random_sample(count, exclude:)
    where.not(id: exclude.id).order(Arel.sql("RANDOM()")).limit(count)
  end

  def to_param
    slug
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      content
      created_at
      id
      meta_image_url
      name
      slug
      title
      updated_at
      video_description
      video_duration
      video_id
      video_thumbnail_url
      video_title
      video_upload_date
    ]
  end

  private

  def create_meta_image
    super(title)
  end
end
