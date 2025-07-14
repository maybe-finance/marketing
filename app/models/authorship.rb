class Authorship < ApplicationRecord
  belongs_to :author
  belongs_to :authorable, polymorphic: true

  validates :author, presence: true
  validates :authorable, presence: true
  validates :role, inclusion: { in: %w[primary contributor editor reviewer], allow_blank: true }

  scope :ordered, -> { order(:position) }
  scope :primary, -> { where(role: "primary") }
  scope :contributors, -> { where(role: "contributor") }
end
