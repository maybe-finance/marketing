class Stock < ApplicationRecord
  include MetaImage
  
  def to_param
    symbol
  end

  private

  def create_meta_image
    super("#{symbol} Stock")
  end
end
