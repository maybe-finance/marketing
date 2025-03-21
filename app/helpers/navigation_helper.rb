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
end
