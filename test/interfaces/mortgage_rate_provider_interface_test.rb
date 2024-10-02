require "test_helper"

module MortgageRateProviderInterfaceTest
  extend ActiveSupport::Testing::Declarative

  test "mortgage rate provider interface" do
    assert_respond_to @subject, :mortgage_rate_30
    assert_respond_to @subject, :mortgage_rate_15
  end

  test "mortgage_rate_30 response contract" do
    VCR.use_cassette "fred/mortgage_rate_30", match_requests_on: [ uri_without_param(:api_key) ] do
      response = @subject.mortgage_rate_30

      assert_respond_to response, :series_id
      assert_respond_to response, :value
      assert_respond_to response, :success?
      assert_respond_to response, :raw_response
    end
  end

  test "mortgage_rate_15 response contract" do
    VCR.use_cassette "fred/mortgage_rate_15", match_requests_on: [ uri_without_param(:api_key) ] do
      response = @subject.mortgage_rate_15

      assert_respond_to response, :series_id
      assert_respond_to response, :value
      assert_respond_to response, :success?
      assert_respond_to response, :raw_response
    end
  end

  private
    delegate :uri_without_param, to: "VCR.request_matchers", private: true
end
