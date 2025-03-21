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
end
