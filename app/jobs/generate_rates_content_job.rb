class GenerateRatesContentJob < ApplicationJob
  queue_as :default

  # Generates content for a specific currency pair.
  # Accepts from_currency and to_currency codes as arguments.
  def perform(from_currency, to_currency)
    # Initialize OpenAI client
    client = OpenAI::Client.new

    Rails.logger.info "Generating content for #{from_currency}/#{to_currency} pair"

    system_prompt = "You are a financial analyst writing a short report analyzing and providing insight into the exchange rate between two currencies based on information from the past few months. No need to link to additional reading or recent developments at the end. No starting heading (as we're doing that separately). Have an opening paragraph. Include subheadings/sections using appropriate markdown (starting with ###). Total length: 1000 words. Output in markdown format. No need to include a disclaimer."

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o-search-preview",
          messages: [ { role: "system", content: system_prompt }, { role: "user", content: "#{from_currency}/#{to_currency}" } ],
          web_search_options: {
            "search_context_size": "high"
          }
        }
      )

      content = response.dig("choices", 0, "message", "content")
      content = content.gsub(/\?utm_source=openai/, "") if content

      ContentBlock.find_or_create_by(
        url_pattern: "/tools/exchange-rate-calculator/#{from_currency}/#{to_currency}",
        match_type: "prefix",
        position: 0
      ).update!(
        title: "Exchange Rate between #{from_currency} and #{to_currency}",
        content: content,
        active: true
      )
      Rails.logger.info "Successfully generated content for #{from_currency}/#{to_currency}"
    rescue StandardError => e
      Rails.logger.error "Failed to generate content for #{from_currency}/#{to_currency}: #{e.message}"
      # Optional: Add error handling/reporting (e.g., notify an error tracking service)
    end
  rescue StandardError => e
    Rails.logger.error "GenerateRatesContentJob failed for pair #{from_currency}/#{to_currency}: #{e.message}"
    Rails.logger.error e.backtrace.join("
")
    # Optional: Add error handling/reporting (e.g., notify an error tracking service)
  end
end
