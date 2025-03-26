module NavigationHelper
  def footer_resources
    [
      {
        text: "Blog",
        path: articles_path
      },
      {
        text: "Tools",
        path: tools_path
      },
      {
        text: "Financial Terms",
        path: terms_path
      },
      {
        text: "Stocks",
        path: stocks_path
      },
      {
        text: "Join Community",
        path: "https://link.maybe.co/discord"
      },
      {
        text: "Self-Host",
        path: "https://github.com/maybe-finance/maybe"
      }
    ]
  end

  def footer_tools
    [
      {
        text: "Compound Interest Calculator",
        path: tool_path("compound-interest-calculator")
      },
      {
        text: "ROI Calculator",
        path: tool_path("roi-calculator")
      },
      {
        text: "Inside Trading Tracker",
        path: tool_path("inside-trading-tracker")
      },
      {
        text: "Financial Freedom Calculator",
        path: tool_path("financial-freedom-calculator")
      },
      {
        text: "Exchange Rate Calculator",
        path: tool_path("exchange-rate-calculator")
      },
      {
        text: "All Tools",
        path: tools_path
      }
    ]
  end

  def footer_stocks
    [
      {
        text: "AAPL",
        path: stock_path("AAPL")
      },
      {
        text: "GOOGL",
        path: stock_path("GOOGL")
      },
      {
        text: "MSFT",
        path: stock_path("MSFT")
      },
      {
        text: "AMZN",
        path: stock_path("AMZN")
      },
      {
        text: "NVDA",
        path: stock_path("NVDA")
      },
      {
        text: "All Stocks",
        path: stocks_path
      }
    ]
  end

  def footer_legal
    [
      {
        text: "Privacy Policy",
        path: privacy_path
      },
      {
        text: "Terms of Service",
        path: tos_path
      }
    ]
  end

  def footer_socials
    [
      {
        icon: "x",
        path: "https://link.maybe.co/discord"
      },
      {
        icon: "x",
        path: "https://github.com/maybe-finance/maybe"
      },
      {
        icon: "x",
        path: "https://x.com/maybe"
      },
      {
        icon: "x",
        path: "https://www.linkedin.com/company/maybe-finance"
      }
    ]
  end

  def header_nav_products
    [
      {
        title: "Tracking",
        description: "Link all your assets and debts",
        path: tracking_features_path,
        icon: "chart-line"
      },
      {
        title: "Transactions",
        description: "Edit and automate transactions effortlessly.",
        path: transactions_features_path,
        icon: "credit-card"
      },
      {
        title: "Budgeting",
        description: "Set limits, track budgets, and optimize finances.",
        path: budgeting_features_path,
        icon: "chart-pie"
      }
    ]
  end

  def header_nav_resources_links
    [
      {
        text: "Blog",
        path: articles_path
      },
      {
        text: "Financial Terms",
        path: terms_path
      },
      {
        text: "Stocks",
        path: stocks_path
      },
      {
        text: "Join Community",
        path: "https://link.maybe.co/discord"
      },
      {
        text: "Self-Host",
        path: "https://github.com/maybe-finance/maybe"
      }
    ]
  end

  def header_nav_resources_more
    [
      {
        text: "X",
        path: "https://x.com/maybe"
      },
      {
        text: "GitHub",
        path: "https://github.com/maybe-finance/maybe"
      },
      {
        text: "Contact".html_safe + " " + lucide_icon("arrow-up-right", class: "text-gray-400 group-hover/contact:text-gray-900 transition-all duration-150 inline w-4 h-4").html_safe,
        path: "mailto:contact@maybe.co"
      },
      {
        text: "Terms of Service",
        path: tos_path
      },
      {
        text: "Privacy Policy",
        path: privacy_path
      }
    ]
  end
end
