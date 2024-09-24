require "test_helper"

module StockPriceProviderInterfaceTest
  extend ActiveSupport::Testing::Declarative

  test "stock price provider interface" do
    assert_respond_to @subject, :stock_price
    assert_respond_to @subject, :stock_prices
  end

  test "stock_price response contract" do
    VCR.use_cassette "synth/stock_price" do
      response = @subject.stock_price ticker: "SPY", date: Date.parse("2024-01-01")

      assert_respond_to response, :ticker
      assert_respond_to response, :date
      assert_respond_to response, :close
      assert_respond_to response, :success?
    end
  end

  test "stock_prices response contract" do
    VCR.use_cassette "synth/stock_prices" do
      response = @subject.stock_prices ticker: "SPY",
        start_date: Date.parse("2024-01-01"),
        end_date: Date.parse("2024-02-01"),
        interval: "day", limit: 10

      assert_respond_to response, :ticker
      assert_respond_to response, :start_date
      assert_respond_to response, :end_date
      assert_respond_to response, :prices
      assert_respond_to response, :success?
    end
  end
end
