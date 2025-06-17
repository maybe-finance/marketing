class Tool::Presenter::InflationCalculator < Tool::Presenter
  attribute :inflation_percentage, :tool_percentage, default: 3.0

  attribute :initial_amount, :tool_float, default: 1000.0
  attribute :years, :tool_float, default: 10.0

  def blank?
    [ initial_amount, years ].all?(&:zero?)
  end

  def future_value
    pv = initial_amount
    r = inflation_percentage
    n = years

    pv * (1 + r)**n
  end

  def present_value
    fv = initial_amount
    r = inflation_percentage
    n = years

    fv / (1 + r)**n
  end

  def inflation_rate
    (inflation_percentage * 100).round(2)
  end

  def amount_increase
    future_value - initial_amount
  end

  def percentage_increase
    (amount_increase * 100 / initial_amount).round(2)
  end

  def amount_loss
    initial_amount - present_value
  end

  def percentage_loss
    (amount_loss * 100 / initial_amount).round(2)
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "inflation-calculator"
    end
end
