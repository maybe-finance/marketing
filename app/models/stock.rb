# == Schema Information
#
# Table name: stocks
#
#  id             :bigint           not null, primary key
#  description    :text
#  legal_name     :string
#  links          :jsonb
#  meta_image_url :string
#  name           :string
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Stock < ApplicationRecord
  include MetaImage
  include Tickers

  def to_param
    symbol
  end

  def to_combobox_display
    "#{symbol} - #{name}"
  end

  private
    def create_meta_image
      super("#{symbol} Stock Price, Information and News")
    end
end
