namespace :data do
  desc "Load stock data from Synth"
  task load_stocks: :environment do
    # https://api.synthfinance.com/tickers
    # 1. Use Faraday to make a GET request to the API, use bearer token for authentication
    # 2. Paginate through the response to get all the data
    # "paging": {
    #   "prev": "/tickers?page=",
    #   "next": "/tickers?page=2",
    #   "total_records": 12059,
    #   "current_page": 1,
    #   "per_page": 500,
    #   "total_pages": 25
    # },
    # 3. Parse the JSON response and save each stock to the database

    page = 1
    loop do
      response = Faraday.get("https://api.synthfinance.com/tickers?page=#{page}") do |req|
        req.headers["Authorization"] = "Bearer #{ENV['SYNTH_API_KEY']}"
        req.headers["X-Source"] = "maybe_marketing"
        req.headers["X-Source-Type"] = "api"
      end

      stocks = JSON.parse(response.body)
      stocks["data"].each do |stock|
        stock_record = Stock.find_or_create_by!(symbol: stock["ticker"]) do |s|
          s.name = stock["name"]
          s.description = stock["description"]
          s.links = stock["links"]
        end
        puts "Created #{stock_record.symbol}"
      end

      break if stocks["paging"]["current_page"] == stocks["paging"]["total_pages"]
      page += 1
    end
  end
end
