module ArticlesHelper

  def calculate_read_time(content)
    words_per_minute = 200
    word_count = content.split.size
    read_time_minutes = (word_count / words_per_minute.to_f).ceil
    "#{read_time_minutes}Min Read"
  end

  ARTICLE_GRADIENTS = [
    "from-rose-400 to-pink-500",
    "from-pink-400 to-rose-500",
    "from-fuchsia-400 to-pink-500",
    "from-pink-400 to-fuchsia-500",
    "from-purple-400 to-pink-500",
    "from-pink-400 to-purple-500",
    "from-violet-400 to-pink-500",
    "from-pink-400 to-violet-500",
    "from-indigo-400 to-pink-500",
    "from-pink-400 to-indigo-500",
    "from-blue-400 to-pink-500",
    "from-pink-400 to-blue-500",
    "from-sky-400 to-pink-500",
    "from-pink-400 to-sky-500",
    "from-cyan-400 to-pink-500",
  ]

  def article_random_gradient(article)
    ARTICLE_GRADIENTS[article.slug.hash % ARTICLE_GRADIENTS.size]
  end
end
