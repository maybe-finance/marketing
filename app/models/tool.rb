class Tool < ApplicationRecord
  CATEGORIES = {
    retirement: {
      name: "Retirement",
      icon_class: "text-cyan-500",
      icon_container_class: "bg-cyan-500/5"
    }
  }

  def to_param
    slug
  end

  def category
    CATEGORIES[category_slug&.to_sym]
  end
end
