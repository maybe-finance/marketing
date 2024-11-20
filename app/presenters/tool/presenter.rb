class Tool::Presenter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :action_name, :string

  delegate :slug, :name, :intro, :content, :meta_image_url, to: :active_record

  private
    attr_reader :active_record

    def active_record
      raise NotImplementedError, "Each Tool::Presenter must know how to fetch its Tool active record"
    end
end
