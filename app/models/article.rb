# == Schema Information
#
# Table name: articles
#
#  id             :bigint           not null, primary key
#  author_name    :string
#  content        :text
#  meta_image_url :string
#  publish_at     :datetime
#  slug           :string
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Article < ApplicationRecord
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
