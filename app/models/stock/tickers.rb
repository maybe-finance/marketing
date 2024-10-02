module Stock::Tickers
  extend ActiveSupport::Concern

  class_methods do
    def full_ticker_name(ticker)
      FULL_NAMES[ticker]
    end

    def known_tickers
      FULL_NAMES.keys
    end

    def stock_market_tickers
      FULL_NAMES.slice(*%w[ VTI SCHB SPTM ]).invert.to_a
    end

    def international_stock_market_tickers
      FULL_NAMES.slice(*%w[ VXUS SCHF SPDW IXUS ]).invert.to_a
    end

    def bond_market_tickers
      FULL_NAMES.slice(*%w[ BND SCHZ SPAB AGG ]).invert.to_a
    end
  end

  private
    FULL_NAMES = {
      "BND" => "BND (Vanguard)",
      "SCHZ" => "SCHZ (Schwab)",
      "SPAB" => "SPAB (SPDR)",
      "AGG" => "AGG (iShares)",
      "VXUS" => "VXUS (Vanguard)",
      "SCHF" => "SCHF (Schwab)",
      "SPDW" => "SPDW (SPDR)",
      "IXUS" => "IXUS (iShares)",
      "SCHB" => "SCHB (Schwab)",
      "SPTM" => "SPTM (SPDR)",
      "VTI" => "VTI (Vanguard)" }
end
