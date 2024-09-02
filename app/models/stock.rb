class Stock < ApplicationRecord
  include MetaImage

  def to_param
    symbol
  end

  private

  def create_meta_image
    super("#{symbol} Stock Price, Information and News")
  end
end
