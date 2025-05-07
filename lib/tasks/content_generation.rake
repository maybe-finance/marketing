namespace :content do
  desc "Enqueues jobs to generate exchange rate content for all currency pairs"
  task generate_rates_content: :environment do
    # Get the list of currencies from the exchange rate calculator presenter
    currencies = Tool::Presenter::ExchangeRateCalculator.new.currency_options.map { |_, code| code }

    # Enqueue a job for each currency pair
    currencies.each do |from_currency|
      currencies.each do |to_currency|
        # Skip same currency pairs
        next if from_currency == to_currency

        Rails.logger.info "Enqueuing content generation job for #{from_currency}/#{to_currency}"
        GenerateRatesContentJob.perform_later(from_currency, to_currency)
      end
    end

    Rails.logger.info "Finished enqueuing all exchange rate content generation jobs."
  end

  desc "Enqueues jobs to generate SEObot content"
  task generate_seobot_content: :environment do
    SyncSeobotJob.perform_later
  end
end
