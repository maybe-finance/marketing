ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = { erb: true }
  config.filter_sensitive_data("<SYNTH_API_KEY>") { ENV["SYNTH_API_KEY"] }
  config.filter_sensitive_data("<FRED_API_KEY>") { ENV["FRED_API_KEY"] }
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

Dir[Rails.root.join("test", "interfaces", "**", "*.rb")].each { |f| require f }
