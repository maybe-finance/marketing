module FeaturesHelper
  def assistant_features
    [
      {
        icon: "messages-square",
        title: "Natural language chat",
        description: "Ask complex questions and get responses that factor in real-time financial data"
      },
      {
        icon: "chart-column-increasing",
        title: "Context-aware",
        description: "Maybe AI understands behaviour & patterns to give personalized, accurate answers."
      },
      {
        icon: "zap",
        title: "Answered in milliseconds",
        description: "Maybe AI is blazing fast by default, so you can answer hard money questions at speed."
      },
      {
        icon: "eye-off",
        title: "Private by default",
        description: "AI is off unless you turn it on, and only the minimum necessary data is shared."
      },
      {
        icon: "link-2",
        title: "Works across all account types",
        description: "Maybe AI can access insights from everything you link."
      },
      {
        icon: "wifi",
        title: "More signal, less noise",
        description: "The assistant stays focused—no filler, no fluff. Every answer is grounded in your data."
      }
    ]
  end
end
