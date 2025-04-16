module Features
  module AssistantHelper
    def load_assistant_data(category)
      YAML.load_file(
        Rails.root.join("config/data/features/assistant/#{category}.yml")
      )
    end

    def tab_categories
      [
        {
          text: "Spending Insights",
          data: "spending",
          icon: "wallet"
        },
        {
          text: "Investment Evaluation",
          data: "investment",
          icon: "chart-candlestick"
        },
        {
          text: "Forecasts & What-ifs",
          data: "forecasts",
          icon: "calendar-fold"
        },
        {
          text: "Asset & Debt analysis",
          data: "analysis",
          icon: "chart-pie"
        },
        {
          text: "Strategic Planning",
          data: "planning",
          icon: "shapes"
        }
      ]
    end
  end
end
