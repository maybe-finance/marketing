class Stock < ApplicationRecord
  def to_param
    symbol
  end
end
