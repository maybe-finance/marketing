module ApplicationHelper
  include Pagy::Frontend

  def title(page_title)
    content_for(:title) { page_title }
  end

  def description(page_description)
    content_for(:description) { page_description }
  end

  def meta_image(meta_image)
    content_for(:meta_image) { meta_image }
  end

  def pagy_nav(pagy)
    html = %(<div class="flex items-center gap-2" aria-label="Pages">)

    if pagy.prev
      html << %(<a href="#{pagy_url_for(pagy, pagy.prev)}" class="flex items-center justify-center w-8 h-8 hover:bg-gray-200 rounded-lg transition-all duration-150 ease-in-out" aria-label="Previous">#{lucide_icon("chevron-left", class: "inline w-4 h-4")}</a>)
    else
      html << %(<button class="flex items-center justify-center w-8 h-8 hover:bg-gray-200 rounded-lg transition-all duration-150 ease-in-out" aria-disabled="true" aria-label="Previous">#{lucide_icon("chevron-left", class: "inline w-4 h-4")}</button>)
    end

    html << %(<div class="flex p-1 rounded-xl items-center gap-2 text-sm bg-gray-100 text-gray-500">)

    pagy.series.each do |item|
      if item.is_a? Integer
        html << %(<a href="#{pagy_url_for(pagy, item)}" class="text-base leading-5 flex items-center hover:bg-gray-300 rounded-md transition-all duration-150 ease-in-out justify-center w-8 h-8">#{item}</a>)
      elsif item.is_a? String
        html << %(<button class="text-base leading-5 flex items-center justify-center w-8 h-8 hover:bg-gray-100 transition-all duration-150 ease-in-out text-black font-[450] bg-white border border-gray-200 rounded-md shadow-xs pointer-events-none" aria-disabled="true" aria-current="page">#{item}</button>)
      elsif item == :gap
        html << %(<button class="text-base leading-5 flex items-center justify-center w-8 h-8 hover:bg-gray-100 transition-all duration-150 ease-in-out rounded-md disabled" aria-disabled="true">...</button>)
      end
    end

    html << %(</div>)

    if pagy.next
      html << %(<a href="#{pagy_url_for(pagy, pagy.next)}" class="flex items-center justify-center w-8 h-8 hover:bg-gray-200 rounded-lg transition-all duration-150 ease-in-out" aria-label="Next">#{lucide_icon("chevron-right", class: "inline w-4 h-4")}</a>)
    else
      html << %(<button class="flex items-center justify-center w-8 h-8 hover:bg-gray-200 rounded-lg transition-all duration-150 ease-in-out" aria-disabled="true" aria-label="Next">#{lucide_icon("chevron-right", class: "inline w-4 h-4")}</button>)
    end

    html << %(</div>)

    html.html_safe
  end

  def markdown(text)
    return "" unless text.present?

    # Remove any lines that are h6 headings (###### ...)
    sanitized_text = text.gsub(/^######.*\n?/, "")

    # Remove any lines that start with "sbb-" (from SEOBot)
    sanitized_text.gsub!(/^sbb-.*\n?/, "")

    options = {
      filter_html:     false,
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

    renderer = CustomMarkdownRenderer.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(sanitized_text).html_safe
  end

  def number_to_k(number)
    if number.present? && number >= 1000
      "#{(number / 1000.0).round(1)}k"
    elsif !number.present?
      "43.7k"
    else
      number.to_s
    end
  end
end

# Custom Markdown Renderer to handle ::: syntax
class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def preprocess(full_document)
    # --- TEMPORARY DEBUGGING LINE ---
    # return "PREPROCESSOR WAS HERE! ORIGINAL CONTAINS '::: faq': #{full_document.include?('::: faq')}"

    doc = full_document.dup # Work on a copy

    # Handle ::: @iframe URL ::: blocks
    # Expects the closing ::: on the immediately following line.
    doc.gsub!(/^:::\s*@iframe\s+(https?:\/\/[^\s]+)\s*?\r?\n^:::\s*$/m) do
      "<div class=\"iframe-container\"><iframe src=\"#{$1}\" width=\"100%\" frameborder=\"0\" allowfullscreen></iframe></div>"
    end

    # Handle other ::: classname blocks (e.g., ::: faq)
    # This will match "::: classname" followed by a newline, then capture the content,
    # and then match the closing ":::".
    # The 'm' option makes '.' match newlines.
    doc.gsub!(/^:::\s*([a-zA-Z0-9_-]+)\s*\r?\n(.*?)^:::\s*$/m) do |match|
      classname = $1
      content = $2
      if classname.start_with?("@") # Avoid reprocessing things like @iframe if somehow missed
        match # Return original match if it's a special @-block not handled above
      else
        # Recursively call markdown for the content inside the block
        # We need to access the main markdown method from ApplicationHelper here.
        # This is a bit tricky directly inside a Redcarpet Renderer instance method
        # without passing a reference or using a global call if possible.
        # For now, let's assume direct call works or we might need to refactor slightly.
        ApplicationController.helpers.markdown(content.strip)
        "<div class=\"#{classname}\">\n#{ApplicationController.helpers.markdown(content.strip)}\n</div>"
      end
    end

    # The above regex should handle both opening and closing for content blocks.
    # A standalone closer ':::' regex might no longer be strictly necessary if all blocks have content
    # and are caught by the rule above. If there's a case for ::: someopening \n content \n ::: \n ::: someotheropening ...,
    # then the more specific block matching above is better.

    doc
  end
end
