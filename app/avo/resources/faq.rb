class Avo::Resources::Faq < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []
  self.search = {
    query: -> { query.ransack(question_cont: params[:q], answer_cont: params[:q], slug_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :question, as: :text
    field :answer, as: :easy_mde
    field :slug, as: :text
    field :category, as: :select, options: Faq::CATEGORIES
    field :author, as: :belongs_to, searchable: true, display_with_value: -> { record.name }

    tabs do
      tab "Author Details" do
        field :authorship, as: :has_one
      end
    end
  end
end
