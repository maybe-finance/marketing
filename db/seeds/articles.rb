Article.find_or_create_by!(slug: "sample-article-1") do |article|
  article.title = "The Future of Fintech: Trends to Watch in 2024"
  article.content = "The financial technology (fintech) landscape is constantly evolving. As we move further into 2024, several key trends are shaping the future of how we manage, spend, and invest our money. From the rise of artificial intelligence (AI) in financial services to the increasing adoption of decentralized finance (DeFi), this article explores the most significant developments that individuals and businesses should keep an eye on."
  article.publish_at = Time.current
  article.author_name = "Jane Doe"
end
