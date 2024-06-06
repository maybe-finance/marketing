class Tool < ApplicationRecord
  CATEGORIES = {
    retirement: {
      name: "Retirement",
      text_class: "text-cyan-500",
      bg_class: "bg-cyan-500/5",
      solid_bg_class: "bg-cyan-500"
    }
  }

  def to_param
    slug
  end

  def category
    CATEGORIES[category_slug&.to_sym]
  end
end
