class Tool::HomeAffordabilityCalculator < Tool::Presenter
  attribute :loan_duration, :tool_integer, default: 0.0

  attribute :loan_interest_rate, :tool_percentage, default: 0.0

  attribute :desired_home_price, :tool_float, default: 0.0
  attribute :down_payment, :tool_float, default: 0.0
  attribute :annual_pre_tax_income, :tool_float, default: 0.0
  attribute :monthly_debt_payments, :tool_float, default: 0.0
  attribute :hoa_plus_pmi, :tool_float, default: 0.0

  def blank?
    [ desired_home_price, down_payment, annual_pre_tax_income, loan_interest_rate, monthly_debt_payments ].all?(&:zero?)
  end

  def mortgage_rate_30
    cached_mortgage_rate 30
  end

  def mortgage_rate_15
    cached_mortgage_rate 15
  end

  def affordable_amount
    segments.first[:value].round(2)
  end

  def plot_data
    { segments: segments, desiredHomePrice: desired_home_price }
  end

  private
    TIME_ZONE_NAME = "Eastern Time (US & Canada)".freeze

    def active_record
      @active_record ||= Tool.find_by! slug: "home-affordability-calculator"
    end

    def mortgage_rate_provider
      @mortgage_rate_provider ||= Provider::Fred.new
    end

    def cached_mortgage_rate(years)
      method_name = "mortgage_rate_#{years}"

      Time.use_zone TIME_ZONE_NAME do
        Rails.cache.fetch method_name, expires_at: Time.current.end_of_day, skip_nil: true do
          response = mortgage_rate_provider.public_send method_name

          if response.success?
            response.value
          end
        end
      end
    end

    def segments
      @segments ||= Tool::HomeAffordability::Segments.new(self).to_a
    end
end
