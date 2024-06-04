module FormsHelper
  def form_field_tag(options = {}, &block)
    options[:class] = [ "form-field", options[:class] ].compact.join(" ")
    tag.div **options, &block
  end
end
