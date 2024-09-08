class Tool::Presenter
  delegate :slug, :name, :intro, :content, :meta_image_url, to: :source

  def initialize(source, _options)
    @source = source
  end

  private
    attr_reader :source
end
