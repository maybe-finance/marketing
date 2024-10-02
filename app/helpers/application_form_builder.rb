class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(object_name, object, template, options)
    options[:html] ||= {}
    options[:html][:class] ||= "space-y-4"

    super(object_name, object, template, options)
  end

  (field_helpers - [ :label, :check_box, :radio_button, :fields_for, :fields, :hidden_field, :file_field ]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})
        default_options = { class: "form-field__input" }
        merged_options = default_options.merge(options)

        return super(method, merged_options) unless options[:label]

        @template.form_field_tag do
          label(method, *label_args(options)) +
          super(method, merged_options.except(:label))
        end
      end
    RUBY_EVAL
  end

  def unit_field(method, options = {})
    default_options = { class: "form-field__input pl-1" }
    default_options[:class] = "form-field__input pl-0" if options[:label_right]
    merged_options = default_options.merge(options)

    # Prepare options for the outer div
    outer_div_options = { class: options.delete(:outer_div_class) }

    return super(method, merged_options) unless options[:label] || options[:label_right]

    @template.form_field_tag(outer_div_options) do
      label_html = if options[:label]
        label_content = label(method, *label_args(options))

        if options[:required] == false
          label_content += @template.tag.span("Optional", class: "form-field__label")
        end

        @template.tag.div(class: "flex items-center justify-between") { label_content }
      end

      content = @template.tag.div(class: "flex items-center") do
        @template.tag.span(options[:unit_symbol], class: "pl-3 pb-2 pt-1 text-sm text-gray-500") +
        text_field(method, merged_options.except(:label)) +
        (@template.tag.span(options[:label_right], class: "text-gray-500 text-xs mr-2") if options[:label_right]).to_s
      end

      label_html.to_s + content
    end
  end

  def submit(value = nil, options = {})
    value, options = nil, value if value.is_a?(Hash)
    default_options = { class: "form-field__submit" }
    merged_options = default_options.merge(options)
    super(value, merged_options)
  end

  private

    def label_args(options)
      case options[:label]
      when Array
        options[:label]
      when String
        [ options[:label], { class: "form-field__label" } ]
      when Hash
        [ nil, options[:label] ]
      else
        [ nil, { class: "form-field__label" } ]
      end
    end
end
