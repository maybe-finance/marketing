class Tool::HomeAffordabilityCalculator < Tool::Presenter
  attr_reader :desired_home_price, :down_payment, :annual_pre_tax_income,
      :loan_duration, :loan_interest_rate, :monthly_debt_payments, :hoa_plus_pmi

  def initialize(**options)
    @active_record = Tool.find_by! slug: "home-affordability-calculator"

    @loan_duration = extract_integer_option(options, :loan_duration)
    @loan_interest_rate = extract_percentage_option(options, :loan_interest_rate)
    @desired_home_price = extract_float_option(options, :desired_home_price)
    @down_payment = extract_float_option(options, :down_payment)
    @annual_pre_tax_income = extract_float_option(options, :annual_pre_tax_income)
    @monthly_debt_payments = extract_float_option(options, :monthly_debt_payments)
    @hoa_plus_pmi = extract_float_option(options, :hoa_plus_pmi)
  end

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
