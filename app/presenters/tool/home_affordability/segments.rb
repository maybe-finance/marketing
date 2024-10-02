class Tool::HomeAffordability::Segments
  def initialize(tool)
    @tool = tool
  end

  def to_a
    [
      { category: "Affordable", value: breakpoints[0].round(2) },
      { category: "Good", value: (breakpoints[1] - breakpoints[0]).round(2) },
      { category: "Caution", value: (breakpoints[2] - breakpoints[1]).round(2) },
      { category: "Risky", value: (breakpoints[3] - breakpoints[2]).round(2) }
    ]
  end

  private
    BASE_DTI_RATIOS = [ 0.20, 0.28, 0.36, 0.44 ].freeze

    PROPERTY_INSURANCE_RATE = 0.65 / 100
    PROPERTY_TAX_RATE = 0.9 / 100

    EXISTING_DEBT_THRESHOLD = 8.0 / 100
    STANDARD_HOUSING_DTI_RATIO = 28.0 / 100
    MAX_TOTAL_DTI_RATIO = 36.0 / 100

    attr_reader :tool

    delegate :annual_pre_tax_income, :loan_duration, :loan_interest_rate,
      :monthly_debt_payments, :hoa_plus_pmi, :down_payment, to: :tool

    def breakpoints
      @breakpoints ||= BASE_DTI_RATIOS.map do |base_dti_ratio|
        adjusted_dti_ratio = base_dti_ratio * debt_to_income_multiplier
        max_monthly_housing_payment = adjusted_dti_ratio * monthly_income

        estimated_loan_amount = present_value(max_monthly_housing_payment)
        estimated_home_price = estimated_loan_amount + down_payment

        monthly_property_costs = estimated_home_price * total_property_rate / 12.0
        adjusted_monthly_payment = max_monthly_housing_payment - monthly_property_costs - hoa_plus_pmi

        affordable_loan_amount = present_value(adjusted_monthly_payment)
        affordable_home_price = affordable_loan_amount + down_payment

        affordable_home_price
      end
    end

    def debt_to_income_multiplier
      if current_debt_to_income_ratio > EXISTING_DEBT_THRESHOLD
        (MAX_TOTAL_DTI_RATIO - current_debt_to_income_ratio) / STANDARD_HOUSING_DTI_RATIO
      else
        1.0
      end
    end

    def current_debt_to_income_ratio
      monthly_debt_payments / monthly_income
    end

    def present_value(monthly_payment)
      rate = loan_interest_rate / 12.0
      periods = loan_duration * 12

      if rate.zero?
        monthly_payment * periods
      else
        monthly_payment * (1 - (1 + rate)**-periods) / rate
      end
    end

    def monthly_income
      annual_pre_tax_income / 12.0
    end

    def total_property_rate
      PROPERTY_INSURANCE_RATE + PROPERTY_TAX_RATE
    end
end
