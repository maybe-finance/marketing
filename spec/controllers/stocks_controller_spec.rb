require 'rails_helper'

RSpec.describe StocksController, type: :controller do
  describe "GET #show" do
    context "with a valid stock ticker" do
      let!(:stock) { Stock.create(symbol: "AAPL", name: "Apple Inc.") }

      it "returns a success response" do
        get :show, params: { ticker: "AAPL" }
        expect(response).to be_successful
      end

      it "assigns the requested stock to @stock" do
        get :show, params: { ticker: "AAPL" }
        expect(assigns(:stock)).to eq(stock)
      end
    end

    context "with an invalid stock ticker" do
      it "raises an ActiveRecord::RecordNotFound error" do
        expect {
          get :show, params: { ticker: "INVALID" }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
