class Avo::Resources::Institution < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :institution_id, as: :text
    field :name, as: :text
    field :country_codes, as: :text
    field :products, as: :text
    field :logo_url, as: :text
    field :website, as: :text
    field :oauth, as: :boolean
    field :primary_color, as: :text
  end
end
