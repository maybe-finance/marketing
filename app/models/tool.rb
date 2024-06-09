class Tool < ApplicationRecord
  CATEGORIES = {
    retirement: {
      name: "Retirement",
      text_class: "text-cyan-500",
      bg_class: "bg-cyan-500/5",
      solid_bg_class: "bg-cyan-500"
    },
    investing: {
      name: "Investing",
      text_class: "text-violet-500",
      bg_class: "bg-violet-500/5",
      solid_bg_class: "bg-violet-500"
    },
    debt: {
      name: "Debt",
      text_class: "text-pink-500",
      bg_class: "bg-pink-500/5",
      solid_bg_class: "bg-pink-500"
    },
    savings: {
      name: "Savings",
      text_class: "text-green-500",
      bg_class: "bg-green-500/5",
      solid_bg_class: "bg-green-500"
    },
    other: {
      name: "Other",
      text_class: "text-yellow-500",
      bg_class: "bg-yellow-500/5",
      solid_bg_class: "bg-yellow-500"
    }
  }

  def to_param
    slug
  end

  def category
    CATEGORIES[category_slug&.to_sym]
  end
end
