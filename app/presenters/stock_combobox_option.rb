class StockComboboxOption
  def initialize(stock)
    @stock = stock
  end

  def id
    @stock.symbol
  end

  def to_combobox_display
    "#{@stock.symbol} #{@stock.name}"
  end
end
