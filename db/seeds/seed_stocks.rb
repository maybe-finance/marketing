
def load_stock_data_from_json(file_name)
    current_dir = File.dirname(__FILE__)
    file_path = File.expand_path(file_name, current_dir)

    data = JSON.parse(File.read(file_path))

    data.each do |record|
      ticker = record["ticker"]
      price = record["price"]
      year = record["year"]

      stock_data = StockPrice.find_or_create_by(ticker: ticker, year: year)
      stock_data.update(price: price) if record.has_key?("price")

      stock_data.save!
    end

    puts "Successfully loaded historical stock prices"
  end

load_stock_data_from_json("stocks.json")
