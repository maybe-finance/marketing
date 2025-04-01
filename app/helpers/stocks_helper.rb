module StocksHelper
  FEATURED_STOCKS = %w[
    AAPL
    GOOG
    MSFT
    AMZN
    TSLA
    NVDA
    META
    NFLX
    JNJ
    VZ
    PG
    MA
    IBM
    PFE
    ABBV
    TM
    V
    WMT
    TSM
    BRKA
  ].freeze

  FEATURED_EXCHANGES = %w[
    NASDAQ
    NYSE
    AMEX
    BATS
    SSE
    Euronext
    LSE
    HKEX
    TSX
    KRX
    BSE
    SZSE
    TSE
    ASX
    NSE
    BME
  ].freeze

  def sector_slug(sector)
    sector.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/-+$/, "")
  end

  def sector_display_name(slug)
    Stock.where(kind: "stock")
         .where.not(mic_code: nil)
         .distinct
         .pluck(:sector)
         .compact
         .find { |sector| sector_slug(sector) == slug }
  end
end
