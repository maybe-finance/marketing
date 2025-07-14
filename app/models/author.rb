class Author < ApplicationRecord
  has_many :authorships, dependent: :destroy
  has_many :articles, through: :authorships, source: :authorable, source_type: "Article"
  has_many :terms, through: :authorships, source: :authorable, source_type: "Term"
  has_many :faqs, through: :authorships, source: :authorable, source_type: "Faq"

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
