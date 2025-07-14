class SyncSeobotJob < ApplicationJob
  queue_as :default

  def perform
    # https://cdn.seobotai.com/#{ENV['SEOBOT_API_KEY']}/system/base.json

    return unless ENV["SEOBOT_API_KEY"].present?

    # Find or create Travis Woods author
    travis_woods = Author.find_or_create_by(name: "Travis Woods") do |author|
      author.slug = "travis-woods"
    end

    conn = Faraday.new(
      url: "https://cdn.seobotai.com/",
      headers: { "Content-Type" => "application/json" }
    )

    begin
      # Fetch the list of all articles
      list_response = conn.get("#{ENV['SEOBOT_API_KEY']}/system/base.json")

      if list_response.success?
        articles_summary_data = JSON.parse(list_response.body)

        articles_summary_data.each do |article_summary|
          slug = article_summary["s"]
          seobot_id = article_summary["id"]

          # Check if article already exists by slug
          unless Article.exists?(slug:)
            Rails.logger.info "Article with slug '#{slug}' not found. Fetching details..."

            # Fetch the full article details
            article_detail_response = conn.get("#{ENV['SEOBOT_API_KEY']}/blog/#{seobot_id}.json")

            if article_detail_response.success?
              article_detail_data = JSON.parse(article_detail_response.body)

              markdown_content = article_detail_data["markdown"]
              # Remove the first H1 heading
              markdown_content = markdown_content.sub(/\A#\s.*\n/, "")

              # Remove any "h6" headings, i.e. ######
              # Example: ###### sbb-itb-98d7454
              markdown_content = markdown_content.gsub(/^#{Regexp.escape('#')}{6}\s+/, "")

              # Remove any lines that start with "sbb-" (from SEOBot)
              markdown_content = markdown_content.gsub(/^sbb-.*\n?/, "")

              # Remove blank lines/spaces at the start and end of the content
              markdown_content = markdown_content.strip

              article = Article.create!(
                title: article_detail_data["headline"],
                slug: article_detail_data["slug"],
                content: markdown_content,
                publish_at: Time.zone.parse(article_detail_data["publishedAt"]), # Assuming 'publishedAt' is a valid date string
                author_name: "Travis Woods",
                meta_image_url: article_detail_data["image"]
              )

              # Create authorship to attach article to Travis Woods
              Authorship.create!(
                author: travis_woods,
                authorable: article,
                role: "primary"
              )
              Rails.logger.info "Successfully created article: #{article_detail_data['headline']}"
            else
              Rails.logger.error "Failed to fetch details for article ID #{seobot_id}. Status: #{article_detail_response.status}, Body: #{article_detail_response.body}"
            end
          else
            Rails.logger.info "Article with slug '#{slug}' already exists. Skipping."
          end
        end
        Rails.logger.info "Successfully synced articles from SEObot."
      else
        Rails.logger.error "Failed to sync articles from SEObot. Status: #{list_response.status}, Body: #{list_response.body}"
      end
    rescue Faraday::Error => e
      Rails.logger.error "Faraday error while syncing from SEObot: #{e.message}"
    rescue JSON::ParserError => e
      Rails.logger.error "JSON parsing error while syncing from SEObot: #{e.message}"
    end
  end
end
