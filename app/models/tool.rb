# == Schema Information
#
# Table name: tools
#
#  id             :bigint           not null, primary key
#  category_slug  :string
#  content        :text
#  description    :text
#  icon           :string
#  intro          :text
#  meta_image_url :string
#  name           :string
#  slug           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Tool < ApplicationRecord
  include MetaImage

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

  class << self
    def from(params)
      tool = find_by! slug: params.delete("slug")
      "Tool::#{tool.slug.tr("-", "_").delete_prefix("401k-").classify}".constantize.new(params.compact_blank)
    end
  end

  def to_param
    slug
  end

  def category
    CATEGORIES[category_slug&.to_sym]
  end

  private
    def create_meta_image
      super(name)
    end
end
