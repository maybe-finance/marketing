namespace :data do
  desc "Migrate existing author_name to Author records"
  task migrate_authors: :environment do
    puts "Starting author migration..."

    # Get unique author names from articles
    author_names = Article.where.not(author_name: [ nil, "" ]).pluck(:author_name).uniq

    author_names.each do |author_name|
      # Find or create the author
      author = Author.find_or_create_by(name: author_name) do |a|
        a.slug = author_name.parameterize
        puts "Creating author: #{author_name}"
      end

      # Find all articles by this author
      articles = Article.where(author_name: author_name)

      articles.each do |article|
        # Create authorship if it doesn't exist
        unless article.authorship
          article.create_authorship!(
            author: author,
            role: "primary",
            position: 0
          )
          puts "  - Linked article '#{article.title}' to author '#{author_name}'"
        end
      end
    end

    puts "Author migration completed!"
    puts "Total authors created: #{Author.count}"
    puts "Total authorships created: #{Authorship.count}"
  end
end
