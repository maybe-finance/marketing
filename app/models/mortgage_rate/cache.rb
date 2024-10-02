class MortgageRate::Cache
  def rate_30
    cached_rate 30
  end

  def rate_15
    cached_rate 15
  end

  private
    TIME_ZONE_NAME = "Eastern Time (US & Canada)"

    def provider
      @provider ||= Provider::Fred.new
    end

    def cached_rate(years)
      method_name = "mortgage_rate_#{years}"

      Time.use_zone TIME_ZONE_NAME do
        Rails.cache.fetch method_name, expires_at: Time.current.end_of_day, skip_nil: true do
          response = provider.public_send method_name

          if response.success?
            response.value
          end
        end
      end
    end
end
