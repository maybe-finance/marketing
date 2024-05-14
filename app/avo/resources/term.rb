class Avo::Resources::Term < Avo::BaseResource
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :title, as: :text
    field :content, as: :textarea
    field :slug, as: :text
    field :video_id, as: :text
    field :video_title, as: :text
    field :video_description, as: :textarea
    field :video_thumbnail_url, as: :text
    field :video_upload_date, as: :date
    field :video_duration, as: :text
  end
end
