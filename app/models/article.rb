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
