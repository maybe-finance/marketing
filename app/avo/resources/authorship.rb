class Avo::Resources::Authorship < Avo::BaseResource
  self.includes = [ :author, :authorable ]

  def fields
    field :id, as: :id
    field :author, as: :belongs_to, searchable: true
    field :authorable, as: :belongs_to, polymorphic_as: :authorable,
      types: [ ::Article, ::Term, ::Faq ]
    field :role, as: :select, options: {
      primary: "Primary",
      contributor: "Contributor",
      editor: "Editor",
      reviewer: "Reviewer"
    }, default: "primary"
    field :position, as: :number, default: 0
  end
end
