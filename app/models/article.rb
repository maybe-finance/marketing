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
  has_one :authorship, as: :authorable, dependent: :destroy
  has_one :author, through: :authorship

  scope :published, -> { where.not(publish_at: nil).where("publish_at <= ?", Time.current) }
  scope :latest, -> { order(publish_at: :desc) }

  # Virtual attribute for Avo
  def author_id
    author&.id
  end

  def author_id=(id)
    if id.blank?
      self.authorship&.destroy
    else
      if self.authorship
        self.authorship.update(author_id: id)
      else
        self.create_authorship(author_id: id, role: "primary")
      end
    end
  end

  include MetaImage

  def self.random_sample(count, exclude:)
    where.not(id: exclude.id).order(Arel.sql("RANDOM()")).limit(count)
  end

  def to_param
    slug
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "author_name", "content", "created_at", "id", "meta_image_url", "publish_at", "slug", "title", "updated_at" ]
  end

  private

  def create_meta_image
    super(title)
  end
end
