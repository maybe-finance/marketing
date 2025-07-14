class Avo::Resources::Term < Avo::BaseResource
  self.find_record_method = -> {
    query.find_by_slug(id)
  }

  self.includes = []
  self.search = {
    query: -> { query.ransack(name_cont: params[:q], title_cont: params[:q], content_cont: params[:q], slug_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :title, as: :text
    field :content, as: :easy_mde
    field :slug, as: :text
    field :author, as: :belongs_to, searchable: true, display_with_value: -> { record.name }
    field :video_id, as: :text
    field :video_description, as: :textarea
    field :video_upload_date, as: :date
    field :video_duration, as: :text

    tabs do
      tab "Author Details" do
        field :authorship, as: :has_one
      end
    end
  end
end
