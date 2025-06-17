# == Schema Information
#
# Table name: stocks
#
#  id             :bigint           not null, primary key
#  country_code   :string
#  description    :text
#  exchange       :string
#  industry       :string
#  kind           :string
#  legal_name     :string
#  links          :jsonb
#  meta_image_url :string
#  mic_code       :string
#  name           :string
#  search_vector  :tsvector
#  sector         :string
#  symbol         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_stocks_on_country_code         (country_code)
#  index_stocks_on_exchange             (exchange)
#  index_stocks_on_kind                 (kind)
#  index_stocks_on_mic_code             (mic_code)
#  index_stocks_on_search_vector        (search_vector) USING gin
#  index_stocks_on_symbol_and_mic_code  (symbol,mic_code) UNIQUE
#
class Stock < ApplicationRecord
  include MetaImage
  include Tickers

  scope :search, ->(query) {
    return nil if query.blank? || query.length < 2

    sanitized_query = query.split.map { |term| "#{term.gsub(/[()&|!:*]/, '')}:*" }.join(" & ")

    select("stocks.*, ts_rank_cd(search_vector, to_tsquery('simple', $1)) AS rank")
      .where("search_vector @@ to_tsquery('simple', :q)", q: sanitized_query)
      .reorder("rank DESC")
  }

  def to_param
    symbol
  end

  def exchanges
    Rails.cache.fetch("stock_exchanges", expires_in: 1.day) do
      Stock.distinct.pluck(:exchange).compact.sort
    end
  end

  def mic_codes
    Rails.cache.fetch("stock_mic_codes", expires_in: 1.day) do
      Stock.distinct.pluck(:mic_code).compact.sort
    end
  end

  def industries
    Rails.cache.fetch("stock_industries", expires_in: 1.day) do
      Stock.distinct.pluck(:industry).compact.sort
    end
  end

  def sectors
    Rails.cache.fetch("stock_sectors", expires_in: 1.day) do
      Stock.distinct.pluck(:sector).compact.sort
    end
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      country_code
      created_at
      description
      exchange
      id
      industry
      kind
      legal_name
      links
      meta_image_url
      mic_code
      name
      sector
      symbol
      updated_at
    ]
  end

  private
    def create_meta_image
      super("#{symbol} Stock Price, Information and News")
    end
end
