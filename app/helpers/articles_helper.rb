module ArticlesHelper

  def calculate_read_time(content)
    words_per_minute = 200
    word_count = content.split.size
    read_time_minutes = (word_count / words_per_minute.to_f).ceil
    "#{read_time_minutes}Min Read"
  end

  def random_tailwind_gradient_class
    tailwind_gradient_classes = [
      "from-pink-500 via-purple-500 to-indigo-500",
      "from-yellow-400 via-red-500 to-pink-500",
      "from-green-400 via-teal-500 to-blue-500",
      "from-indigo-400 via-blue-500 to-cyan-500",
      "from-red-400 via-pink-500 to-purple-500",
      "from-purple-400 via-indigo-500 to-blue-500",
      "from-green-400 via-lime-500 to-yellow-500",
      "from-yellow-400 via-orange-500 to-red-500",
      "from-blue-400 via-cyan-500 to-teal-500",
      "from-orange-400 via-red-500 to-pink-500",
      "from-teal-400 via-green-500 to-lime-500",
      "from-fuchsia-400 via-purple-500 to-indigo-500",
      "from-rose-400 via-red-500 to-yellow-500",
      "from-cyan-400 via-teal-500 to-green-500",
      "from-lime-400 via-yellow-500 to-orange-500"
    ]
    "bg-gradient-to-t #{tailwind_gradient_classes.sample} rounded-xl"
  end

end
