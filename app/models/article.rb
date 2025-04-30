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

class Article < ApplicationRecord
  scope :published, -> { where.not(publish_at: nil).where("publish_at <= ?", Time.current) }
  scope :latest, -> { order(publish_at: :desc) }

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
