# == Schema Information
#
# Table name: faqs
#
#  id             :integer          not null, primary key
#  question       :string
#  answer         :text
#  slug           :string
#  category       :string
#  meta_image_url :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_faqs_on_category  (category)
#  index_faqs_on_slug      (slug) UNIQUE
#

class Faq < ApplicationRecord
  has_one :authorship, as: :authorable, dependent: :destroy
  has_one :author, through: :authorship

  include MetaImage

  # Constants for category options
  CATEGORIES = [
    "Getting Started",
    "Budgeting",
    "Investing",
    "Retirement",
    "Taxes",
    "Banking",
    "Credit & Debt",
    "Insurance"
  ].freeze

  # Validations
  validates :question, presence: true
  validates :answer, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :alphabetical, -> { order(:question) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods
  def self.random_sample(count, exclude:)
    where.not(id: exclude.id).order(Arel.sql("RANDOM()")).limit(count)
  end

  def self.search(query)
    return all if query.blank?

    where("question ILIKE :query OR answer ILIKE :query", query: "%#{query}%")
  end

  def self.categories
    distinct.pluck(:category).compact.sort
  end

  # Instance methods
  def to_param
    slug
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      answer
      category
      created_at
      id
      meta_image_url
      question
      slug
      updated_at
    ]
  end

  private

  def create_meta_image
    super(question)
  end
end
