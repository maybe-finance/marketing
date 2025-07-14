class Avo::Resources::Article < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []
  self.search = {
    query: -> { query.ransack(title_cont: params[:q], slug_cont: params[:q], content_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :slug, as: :text
    field :content, as: :easy_mde
    field :publish_at, as: :date_time
    field :author_name, as: :text, hide_on: [ :forms ]
    field :author, as: :belongs_to, searchable: true, display_with_value: -> { record.name }

    tabs do
      tab "Author Details" do
        field :authorship, as: :has_one
      end
    end
  end

  def update_model_record(model, params, **args)
    author_id = params.delete(:author_id)

    super(model, params, **args)

    if author_id.present?
      # Remove existing authorship if present
      model.authorship&.destroy

      # Create new authorship with the selected author
      model.create_authorship(author_id: author_id, role: "primary")
    elsif author_id == ""
      # If author_id is blank, remove the authorship
      model.authorship&.destroy
    end

    model
  end
end
