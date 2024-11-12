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

      # Collect records for bulk insert
      new_stocks = stocks["data"].map do |stock|
        {
          symbol: stock["ticker"],
          name: stock["name"],
          description: stock["description"],
          links: stock["links"],
          exchange: stock.dig("exchange", "acronym"),
          mic_code: stock.dig("exchange", "mic_code"),
          country_code: stock.dig("exchange", "country_code"),
          kind: stock["kind"],
          industry: stock["industry"],
          sector: stock["sector"],
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      # Bulk upsert using unique constraint on symbol and mic_code
      Stock.upsert_all(
        new_stocks,
        unique_by: [ :symbol, :mic_code ],
        returning: false
      )

      puts "Processed page #{page}/#{stocks['paging']['total_pages']} (#{new_stocks.size} stocks)"

      break if stocks["paging"]["current_page"] == stocks["paging"]["total_pages"]
      page += 1
    end
  end
end
