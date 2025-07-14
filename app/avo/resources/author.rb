class Avo::Resources::Author < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []
  self.search = {
    query: -> { query.ransack(name_cont: params[:q], bio_cont: params[:q], email_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :slug, as: :text, required: true
    field :bio, as: :textarea
    field :avatar_url, as: :text
    field :position, as: :text
    field :email, as: :text
    field :social_links, as: :code, language: "javascript"

    tabs do
      tab "Content" do
        field :articles, as: :has_many
        field :terms, as: :has_many
        field :faqs, as: :has_many
      end
    end
  end
end
