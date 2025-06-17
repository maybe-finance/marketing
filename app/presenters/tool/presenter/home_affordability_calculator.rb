class Tool::Presenter::HomeAffordabilityCalculator < Tool::Presenter
  attribute :loan_duration, :tool_integer, default: 30

  attribute :loan_interest_rate, :tool_percentage, default: 6.5

  attribute :desired_home_price, :tool_float, default: 400000.0
  attribute :down_payment, :tool_float, default: 80000.0
  attribute :annual_pre_tax_income, :tool_float, default: 100000.0
  attribute :monthly_debt_payments, :tool_float, default: 500.0
  attribute :hoa_plus_pmi, :tool_float, default: 300.0

  def blank?
    [ desired_home_price, down_payment, annual_pre_tax_income, loan_interest_rate, monthly_debt_payments ].all?(&:zero?)
  end

  def mortgage_rate_30
    mortgage_rate_cache.rate_30
  end

  def mortgage_rate_15
    mortgage_rate_cache.rate_15
  end

  def affordable_amount
    segments.first[:value].round(2)
  end

  def plot_data
    { segments: segments, desiredHomePrice: desired_home_price }
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "home-affordability-calculator"
    end

    def mortgage_rate_cache
      @mortgage_rate_cache ||= MortgageRate::Cache.new
    end

    def segments
      @segments ||= Tool::HomeAffordability::Segments.new(self).to_a
    end
end
