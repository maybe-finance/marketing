class Avo::Resources::Faq < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :question, as: :text
    field :answer, as: :easy_mde
    field :slug, as: :text
    field :category, as: :select, options: Faq::CATEGORIES
  end
end
