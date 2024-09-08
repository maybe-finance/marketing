class Tool::InflationCalculator < Tool::Presenter
  attr_reader :years, :initial_amount

  def initialize(_, **options)
    super

    @initial_amount = (options[:initial_amount].presence || 0).to_d
    @inflation_percentage = (options[:inflation_percentage].presence || 0).to_d / 100
    @years = (options[:years].presence || 0).to_d
  end

  def blank?
    [ initial_amount, inflation_percentage, years ].all?(&:zero?)
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
    attr_reader :inflation_percentage
end
