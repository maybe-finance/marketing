require "test_helper"

class MortgageRate::CacheTest < ActiveSupport::TestCase
  test "caching" do
    with_cache_store do
      cache = MortgageRate::Cache.new

      VCR.use_cassette "fred/mortgage_rate_30", record: :once, match_requests_on: [ uri_without_param(:api_key) ] do
        assert_equal "6.09", cache.rate_30
        assert_equal "6.09", cache.rate_30 # Raises if not cached because of record: :once
      end
    end
  end

  private
    delegate :uri_without_param, to: "VCR.request_matchers", private: true

    def with_cache_store
      previous_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache.clear
      Rails.cache = previous_cache
    end
end
