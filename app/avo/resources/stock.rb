class Avo::Resources::Stock < Avo::BaseResource
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :symbol, as: :text
    field :name, as: :text
    field :legal_name, as: :text
    field :links, as: :text
    field :description, as: :textarea
  end
end
