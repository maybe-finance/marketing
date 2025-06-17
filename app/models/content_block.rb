class ContentBlock < ApplicationRecord
  # Ensure url_pattern and match_type are present
  validates :url_pattern, presence: true
  validates :match_type, presence: true

  # Define the possible match types using enum
  enum :match_type, {
    exact: "exact",
    prefix: "prefix",
    regex: "regex"
  }, suffix: true

  # Scope to get only active content blocks
  scope :active, -> { where(active: true) }

  # Scope to order content blocks by position
  scope :ordered, -> { order(position: :asc) }

  # Find all active, ordered content blocks matching the given path
  def self.for_path(path)
    active.ordered.select { |block| block.matches_path?(path) }
  end

  # Check if this specific block matches the given path
  def matches_path?(path)
    case match_type
    when "exact"
      url_pattern == path
    when "prefix"
      # Ensure prefix matches start correctly (e.g., /tools/ should match /tools/abc but not /toolset/)
      path.start_with?(url_pattern) && (path.length == url_pattern.length || path[url_pattern.length] == "/")
    when "regex"
      begin
        Regexp.new(url_pattern).match?(path)
      rescue RegexpError
        # Log error or handle invalid regex patterns gracefully
        Rails.logger.error("Invalid regex for ContentBlock ##{id}: #{url_pattern}")
        false
      end
    else
      false
    end
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      active
      content
      created_at
      id
      match_type
      position
      title
      updated_at
      url_pattern
    ]
  end
end
