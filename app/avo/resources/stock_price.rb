class Avo::Resources::StockPrice < Avo::BaseResource
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :ticker, as: :text
    field :price, as: :number
    field :year, as: :number
    field :month, as: :number
    field :date, as: :text
    field :created_at, as: :date_time
    field :updated_at, as: :date_time
  end
end
