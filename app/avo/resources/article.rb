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
    field :author, as: :belongs_to, searchable: true, display_with_value: -> { record.name }, use_resource: Avo::Resources::Author

    tabs do
      tab "Author Details" do
        field :authorship, as: :has_one
      end
    end
  end

  def create_model_record(model, params, **args)
    Rails.logger.debug "=== Article Create Params: #{params.inspect}"
    
    # Try different possible param keys
    author_id = params.delete(:author_id) || params.delete("author_id") || params.dig(:author, :id) || params.dig("author", "id")
    Rails.logger.debug "=== Author ID extracted: #{author_id.inspect}"

    super(model, params, **args)

    handle_author_assignment(model, author_id)

    model
  end

  def update_model_record(model, params, **args)
    Rails.logger.debug "=== Article Update Params: #{params.inspect}"
    
    # Try different possible param keys
    author_id = params.delete(:author_id) || params.delete("author_id") || params.dig(:author, :id) || params.dig("author", "id")
    Rails.logger.debug "=== Author ID extracted: #{author_id.inspect}"

    super(model, params, **args)

    handle_author_assignment(model, author_id)

    model
  end

  private

  def handle_author_assignment(model, author_id)
    Rails.logger.debug "=== Handling author assignment with ID: #{author_id.inspect}"
    
    if author_id.present?
      # Remove existing authorship if present
      model.authorship&.destroy
      Rails.logger.debug "=== Destroyed existing authorship"

      # Create new authorship with the selected author
      authorship = model.create_authorship(author_id: author_id, role: "primary")
      Rails.logger.debug "=== Created new authorship: #{authorship.inspect}, valid: #{authorship.valid?}, errors: #{authorship.errors.full_messages}"
    elsif author_id == ""
      # If author_id is blank, remove the authorship
      model.authorship&.destroy
      Rails.logger.debug "=== Removed authorship (blank author_id)"
    end
  end
end
