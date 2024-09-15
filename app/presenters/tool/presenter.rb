class Tool::Presenter
  delegate :slug, :name, :intro, :content, :meta_image_url, to: :active_record

  private
    attr_reader :active_record

    def active_record
      raise NotImplementedError, "Each Tool::Presenter must know how to fetch its Tool active record"
    end

    def extract_float_option(options, key)
      (options[key].presence || 0).to_f
    end

    def extract_integer_option(options, key)
      extract_float_option(options, key).to_i
    end

    def extract_percentage_option(options, key)
      extract_float_option(options, key) / 100
    end
end
