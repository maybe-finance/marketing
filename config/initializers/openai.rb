if ENV["OPENAI_API_KEY"].present?
  OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_API_KEY")
    config.log_errors = Rails.env.development?
  end
end
