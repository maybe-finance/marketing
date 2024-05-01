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
end
