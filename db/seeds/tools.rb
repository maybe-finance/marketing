tools = [
  {
    name: "Financial Freedom Calculator",
    slug: "financial-freedom-calculator",
    intro: "How long will your savings last?",
    description: "See how long your savings will last by accounting for your monthly expenses and savings growth rate.",
    category_slug: "retirement",
    icon: "bar-chart-4"
  },
  {
    name: "ROI Calculator",
    slug: "roi-calculator",
    intro: "Calculate the return on your investments and evaluate the gain or loss.",
    description: "See how to calculate the return on your investments and evaluate the gain or loss.",
    category_slug: "investing",
    icon: "line-chart"
  },
  {
    name: "Loan Calculator",
    slug: "loan-calculator",
    intro: "The Loan Calculator allows you to easily plan your loans and understand your repayment schedule.",
    description: "See how to easily plan your loans and understand your repayment schedule.",
    category_slug: "debt",
    icon: "scale"
  },
  {
    name: "Inflation Calculator",
    slug: "inflation-calculator",
    intro: "Calculate how inflation is impacting an asset's future price and your future buying power.",
    description: "See how inflation is impacting an asset's future price and your future buying power.",
    category_slug: "other",
    icon: "infinity"
  },
  {
    name: "Compound Interest Calculator",
    slug: "compound-interest-calculator",
    intro: "See how your investments grow over time by earning interest on interest and letting your money work for you.",
    description: "See how your investments grow over time by earning interest on interest and letting your money work for you.",
    category_slug: "savings",
    icon: "line-chart"
  },
  {
    name: "401k Retirement Calculator",
    slug: "401k-retirement-calculator",
    intro: "Calculate how much you need to save for retirement and how much you can expect to have saved by the time you retire.",
    description: "See how much your 401k balance and payout amount in retirement will work for you.",
    category_slug: "retirement",
    icon: "bar-chart-4"
  },
  {
    name: "Bogleheads Growth Calculator",
    slug: "bogleheads-growth-calculator",
    intro: "Calculate how much you could make on future investments in the Bogleheads three-fund portfolio.",
    description: "See the performance of a Bogleheads three-fund portfolio based on the past 20 years.",
    category_slug: "investing",
    icon: "bar-chart-4"
  },
  {
    name: "Home Affordability Calculator",
    slug: "home-affordability-calculator",
    intro: "Calculate how much house you can afford based on your income, loan details, debt and more!",
    description: "See how much house you can afford based on your income, loan details, debt and more!",
    category_slug: "investing",
    icon: "home"
  },
  {
    name: "Early Mortgage Payoff Calculator",
    slug: "early-mortgage-payoff-calculator",
    intro: "See the impact of making extra payments on your mortgage or investing the difference.",
    description: "Calculate how much time and interest you can save by making additional payments on your mortgage or investing the difference.",
    category_slug: "debt",
    icon: "home"
  },
  {
    name: "Stock Portfolio Backtest",
    slug: "stock-portfolio-backtest",
    intro: "See how a portfolio would have performed, just remember that past performance isn’t indicative of future returns.",
    description: "See how a portfolio would have performed, just remember that past performance isn’t indicative of future returns.",
    category_slug: "investing",
    icon: "bar-chart-4"
  },
  {
    name: "Exchange Rate Calculator",
    slug: "exchange-rate-calculator",
    intro: "Convert between currencies and track historical exchange rates",
    description: "Calculate currency exchange rates and view historical trends between different currencies.",
    category_slug: "other",
    icon: "currency"
  }
]

tools.each do |attrs|
  Tool.find_or_create_by!(slug: attrs[:slug]) do |t|
    t.name = attrs[:name]
    t.intro = attrs[:intro]
    t.description = attrs[:description]
    t.category_slug = attrs[:category_slug]
    t.icon = attrs[:icon]
  end
end
