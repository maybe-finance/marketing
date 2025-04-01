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

  FEATURED_EXCHANGES = [
    [ "AMEX", "us" ],
    [ "ASX", "au" ],
    [ "BATS", "us" ],
    [ "BME", "es" ],
    [ "Euronext", "eu" ],
    [ "HKEX", "hk" ],
    [ "KRX", "kr" ],
    [ "LSE", "gb" ],
    [ "NASDAQ", "us" ],
    [ "NSE", "in" ],
    [ "NYSE", "us" ],
    [ "SSE", "cn" ],
    [ "TSX", "ca" ],
    [ "MSE", "in" ],
    [ "SZSE", "cn" ],
    [ "TSE", "jp" ]
  ]

  FEATURED_SECTORS = [
    "Banking",
    "Healthcare",
    "Energy",
    "Automotive",
    "Industrials",
    "Utilities",
    "Real Estate"
  ]


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

  def featured_quick_links
    {
      stocks: FEATURED_STOCKS.sample(2),
      exchanges: FEATURED_EXCHANGES.sample(2).map { |exchange, country_code|
        {
          name: exchange,
          country_code: country_code.upcase
        }
      },
      sectors: FEATURED_SECTORS.sample(2)
    }
  end
end
