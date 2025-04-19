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

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    text.present? ? markdown.render(text).html_safe : ""
  end
end
