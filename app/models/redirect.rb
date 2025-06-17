class Redirect < ApplicationRecord
  REDIRECT_TYPES = %w[permanent temporary].freeze
  PATTERN_TYPES = %w[exact wildcard regex].freeze

  validates :source_path, presence: true, uniqueness: true
  validates :destination_path, presence: true
  validates :redirect_type, inclusion: { in: REDIRECT_TYPES }
  validates :pattern_type, inclusion: { in: PATTERN_TYPES }
  validates :priority, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :by_priority, -> { order(:priority) }

  def status_code
    redirect_type == "permanent" ? 301 : 302
  end

  def matches_path?(request_path)
    case pattern_type
    when "exact"
      source_path == request_path
    when "wildcard"
      File.fnmatch(source_path, request_path)
    when "regex"
      Regexp.new(source_path).match?(request_path)
    else
      false
    end
  rescue RegexpError
    false
  end

  def process_destination(request_path)
    case pattern_type
    when "exact", "wildcard"
      destination_path
    when "regex"
      request_path.gsub(Regexp.new(source_path), destination_path)
    else
      destination_path
    end
  rescue RegexpError
    destination_path
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      active
      created_at
      destination_path
      id
      pattern_type
      priority
      redirect_type
      source_path
      updated_at
    ]
  end
end
