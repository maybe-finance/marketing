class Avo::Resources::Redirect < Avo::BaseResource
  self.title = :source_path
  self.includes = []
  self.search = {
    query: -> { query.ransack(source_path_cont: params[:q], destination_path_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id, hide_on: [ :new, :edit ]

    field :source_path, as: :text, required: true, help: "Examples: /old-page, /blog/*, ^/article/(\\d+)"
    field :destination_path, as: :text, required: true, help: "Examples: /new-page, /posts, /posts/\\1 (for regex capture)"

    field :redirect_type, as: :select, required: true, options: Redirect::REDIRECT_TYPES.map { |type| [ type.humanize, type ] }

    field :pattern_type, as: :select, required: true, options: Redirect::PATTERN_TYPES.map { |type| [ type.humanize, type ] }

    field :active, as: :boolean, required: true
    field :priority, as: :number, required: true, help: "Lower numbers have higher priority"
  end
end
