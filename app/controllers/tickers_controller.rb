class TickersController < ApplicationController
  def open_close
    tickers = params[:tickers]
    start_date = params[:start_date]
    end_date = params[:end_date]

    results = tickers.map do |ticker|
      response = Faraday.get(
        "https://api.synthfinance.com/tickers/#{ticker}/open-close",
        { start_date: start_date, end_date: end_date, interval: "month", limit: 500 },
        { "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}" }
      )

      { ticker => JSON.parse(response.body)["prices"] }
    end

    render json: results
  end
end
