require "zlib"

module ArticlesHelper
  WORDS_PER_MINUTE = 180

  def article_reading_time(article)
    words_count = article.content.split.size
    minutes = (words_count.to_f / WORDS_PER_MINUTE).ceil
    "#{minutes} min read"
  end

  ARTICLE_GRADIENTS = [
    "from-[#98aaba] to-[#ffbd59]",
    "from-[#fbc2eb] to-[#a6c1ee]",
    "from-cyan-400 to-blue-500",
    "from-[#f6d365] to-[#fda085]",
    "from-[#f093fb] to-[#f5576c]"
  ]

  def article_gradient(article)
    ARTICLE_GRADIENTS[Zlib.crc32(article.to_param) % ARTICLE_GRADIENTS.size]
  end

  def author_image_tag(name, **options)
    image_path = "authors/#{name.parameterize}.jpg"

    if image_exists?(image_path)
      image_tag image_path, **options.reverse_merge(alt: name)
    else
      render "articles/author_placeholder", name: name, options: options
    end
  end

  private

  def image_exists?(path)
    file_path = Rails.root.join("app", "assets", "images", path)
    File.exist?(file_path)
  end
end
