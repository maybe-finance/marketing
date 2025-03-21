module NavigationHelper
  def footer_resources
    [
      {
        text: "Articles",
        path: articles_path,
        class: "text-[#141414]"
      },
      {
        text: "Financial Terms",
        path: terms_path,
        class: "text-[#141414]"
      },
      {
        text: "Tools",
        path: tools_path,
        class: "text-[#141414]"
      },
      {
        text: "Contribute",
        path: "https://github.com/maybe-finance/maybe",
        class: "text-[#141414]"
      }
    ]
  end

  def footer_tools
    [
      {
        text: "Compound Interest Calculator",
        path: tool_path("compound-interest-calculator"),
        class: "text-[#141414]"
      },
      {
        text: "ROI Calculator",
        path: tool_path("roi-calculator"),
        class: "text-[#141414]"
      },
      {
        text: "Inside Trading Tracker",
        path: tool_path("inside-trading-tracker"),
        class: "text-[#141414]"
      },
      {
        text: "Financial Freedom Calculator",
        path: tool_path("financial-freedom-calculator"),
        class: "text-[#141414]"
      },
      {
        text: "Exchange Rate Calculator",
        path: tool_path("exchange-rate-calculator"),
        class: "text-[#141414]"
      },
      {
        text: "All Tools",
        path: tools_path,
        class: "text-[#141414]"
      }
    ]
  end
end
