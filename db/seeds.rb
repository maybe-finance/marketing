# Tools
tools = [
  {
    "name": "Financial Freedom Calculator",
    "slug": "financial-freedom-calculator",
    "intro": "How long will your savings last?",
    "description": "See how long your savings will last by accounting for your monthly expenses and savings growth rate.",
    "category_slug": "retirement",
    "icon": "bar-chart-4"
  },
  {
    "name": "ROI Calculator",
    "slug": "roi-calculator",
    "intro": "Calculate the return on your investments and evaluate the gain or loss.",
    "description": "See how to calculate the return on your investments and evaluate the gain or loss.",
    "category_slug": "investing",
    "icon": "line-chart"
  },
  {
    "name": "Loan Calculator",
    "slug": "loan-calculator",
    "intro": "The Loan Calculator allows you to easily plan your loans and understand your repayment schedule.",
    "description": "See how to easily plan your loans and understand your repayment schedule.",
    "category_slug": "debt",
    "icon": "scale"
  },
  {
    "name": "Inflation Calculator",
    "slug": "inflation-calculator",
    "intro": "Calculate how inflation is impacting an asset’s future price and your future buying power.",
    "description": "See how inflation is impacting an asset’s future price and your future buying power.",
    "category_slug": "other",
    "icon": "infinity"
  }
]

tools.each do |tool|
  Tool.find_or_create_by!(slug: tool[:slug]) do |t|
    t.name = tool[:name]
    t.intro = tool[:intro]
    t.description = tool[:description]
    t.category_slug = tool[:category_slug]
    t.icon = tool[:icon]
  end
end
