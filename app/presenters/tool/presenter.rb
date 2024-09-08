class Tool::Presenter
  delegate :slug, :name, :intro, :content, :meta_image_url, to: :active_record

  def initialize(active_record, _options)
    @active_record = active_record
  end

  private
    attr_reader :active_record

    def extract_decimal_option(options, key)
      (options[key].presence || 0).to_d
    end

    def extract_percentage_option(options, key)
      extract_decimal_option(options, key) / 100
    end
end
