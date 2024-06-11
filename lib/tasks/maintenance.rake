namespace :maintenance do
  desc "Create meta images for all content"
  task create_meta_images: :environment do
    Article.all.each do |article|
      article.touch
    end
    Term.all.each do |term|
      term.touch
    end
    Tool.all.each do |tool|
      tool.touch
    end
  end
end
