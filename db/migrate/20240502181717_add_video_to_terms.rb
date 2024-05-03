class AddVideoToTerms < ActiveRecord::Migration[7.2]
  def change
  add_column :terms, :video_id, :string
  add_column :terms, :video_title, :string
  add_column :terms, :video_description, :text
  add_column :terms, :video_thumbnail_url, :string
  add_column :terms, :video_upload_date, :date
  add_column :terms, :video_duration, :string
  end
end
