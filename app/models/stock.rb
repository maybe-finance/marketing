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
#  search_vector  :tsvector
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stocks_on_search_vector  (search_vector) USING gin
#
class Stock < ApplicationRecord
  include MetaImage
  include Tickers

  scope :search, ->(query) {
    return nil if query.blank? || query.length < 2

    sanitized_query = query.split.map { |term| "#{term}:*" }.join(" & ")

    select("stocks.*, ts_rank_cd(search_vector, to_tsquery('simple', $1)) AS rank")
      .where("search_vector @@ to_tsquery('simple', :q)", q: sanitized_query)
      .reorder("rank DESC")
  }

  def to_param
    symbol
  end

  private
    def create_meta_image
      super("#{symbol} Stock Price, Information and News")
    end
end
