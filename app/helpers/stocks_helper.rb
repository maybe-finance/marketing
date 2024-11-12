module StocksHelper
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
