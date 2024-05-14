class Avo::Resources::Article < Avo::BaseResource
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :slug, as: :text
    field :content, as: :textarea
    field :publish_at, as: :date_time
    field :author_name, as: :text
  end
end
