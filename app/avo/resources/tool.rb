class Avo::Resources::Tool < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []

  def fields
    field :id, as: :id
    field :name, as: :text
    field :slug, as: :text
    field :icon, as: :text

    field :category_slug, as: :select, options: -> do
      [ [ "No category", "" ] ] + Tool::CATEGORIES.keys.map { |key| [ key.to_s.humanize, key.to_s ] }
    end

    field :intro, as: :markdown
    field :description, as: :textarea
    field :content, as: :markdown
  end
end
