class Avo::Resources::ContentBlock < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :content, as: :textarea
    field :url_pattern, as: :text
    field :match_type, as: :text
    field :position, as: :number
    field :active, as: :boolean
  end
end
