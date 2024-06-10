module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def description(page_description)
    content_for(:description) { page_description }
  end

  def meta_image(meta_image)
    content_for(:meta_image) { meta_image }
  end

  def markdown(text)
    options = {
      filter_html:     true,
      hard_wrap:       true,
      # link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      tables:             true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    text.present? ? markdown.render(text).html_safe : ""
  end
end
