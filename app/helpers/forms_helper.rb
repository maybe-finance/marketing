module FormsHelper
  def form_field_tag(options = {}, &block)
    options[:class] = [ "form-field", options[:class] ].compact.join(" ")
    tag.div(**options, &block)
  end

  def range_input_slider(options = {})
    tag.input(
      type: "range",
      data: {
        controller: "range-input",
        synchronized_input_target: "input",
        action: "synchronized-input#syncValue range-input#update input-sync->range-input#update"
      },
      **options
    )
  end
end
