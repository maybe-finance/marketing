class Avo::Resources::Term < Avo::BaseResource
  self.find_record_method = -> {
    # When using friendly_id, we need to check if the id is a slug or an id.
    # If it's a slug, we need to use the find_by_slug method.
    # If it's an id, we need to use the find method.
    # If the id is an array, we need to use the where method in order to return a collection.
    if id.is_a?(Array)
      id.first.to_i == 0 ? query.where(slug: id) : query.where(id: id)
    else
      id.to_i == 0 ? query.find_by_slug(id) : query.find(id)
    end
  }

  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :title, as: :text
    field :content, as: :markdown
    field :slug, as: :text
    field :video_id, as: :text
    field :video_title, as: :text
    field :video_description, as: :textarea
    field :video_thumbnail_url, as: :text
    field :video_upload_date, as: :date
    field :video_duration, as: :text
  end
end
