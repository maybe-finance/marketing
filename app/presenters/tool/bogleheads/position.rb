class Tool::Bogleheads::Position
  def initialize(ticker:, allocation:)
    @ticker = ticker
    @allocation = allocation
  end

  def ticker_name
    Stock.full_ticker_name(ticker)
  end

  def earliest_known_date
    @earliest_known_date ||= StockPrice.where(ticker: ticker).minimum(:date).to_date
  end

  def latest_known_date
    @latest_known_date ||= StockPrice.where(ticker: ticker).maximum(:date).to_date
  end

  def value_at(year:, month:, purchase_date:)
    stock_price(year: year, month: month).price * shares(purchase_date: purchase_date)
  end

  private
    attr_reader :ticker, :allocation

    def shares(purchase_date:)
      allocation / stock_price(date: purchase_date).price
    end

    def stock_price(date: nil, year: nil, month: nil)
      if date.present?
        result = all_prices.find { |stock_price| stock_price.date == date.to_s }
        result || StockPrice.new(ticker: ticker, price: 0, date: date)
      else
        result = all_prices.find { |stock_price| stock_price.year == year && stock_price.month == month }
        result || StockPrice.new(ticker: ticker, price: 0, year: year, month: month)
      end
    end

    # `#all_prices` caches all stock prices in-memory to let ruby do the heavy lifting instead of the database.
    def all_prices
      @all_prices ||= StockPrice.where(ticker: ticker)
    end
end
