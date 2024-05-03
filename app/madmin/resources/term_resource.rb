class TermResource < Madmin::Resource
  # Attributes
  attribute :id, form: false, index: false
  attribute :name
  attribute :title
  attribute :content
  attribute :slug
  attribute :created_at, form: false, index: false
  attribute :updated_at, form: false, index: false
  attribute :video_id
  attribute :video_title
  attribute :video_description
  attribute :video_thumbnail_url
  attribute :video_upload_date
  attribute :video_duration

  def self.model_find(id)
    model.find_by!(slug: id)
  end

  # Associations

  # Uncomment this to customize the display name of records in the admin area.
  def self.display_name(record)
    record.name
  end

  # Uncomment this to customize the default sort column and direction.
  def self.default_sort_column
    "name"
  end
  #
  def self.default_sort_direction
    "asc"
  end
end
