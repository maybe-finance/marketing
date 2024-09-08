class Tool::CompoundInterestCalculator < Tool::Presenter
  attr_reader :years_to_grow

  def initialize(_, **options)
    super

    @initial_investment = extract_decimal_option(options, :initial_investment)
    @monthly_contribution = extract_decimal_option(options, :monthly_contribution)
    @years_to_grow = extract_decimal_option(options, :years_to_grow).clamp(0, 150) # guard against malicious input
    @annual_interest_rate = extract_percentage_option(options, :annual_interest_rate)
  end

  def blank?
    [ initial_investment, monthly_contribution, years_to_grow, annual_interest_rate ].all?(&:zero?)
  end

  def total_value
    plot_data.last[:currentTotalValue].round(2)
  end

  def series_data
    {
      contributed: {
        name: "Contributed",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      interest: {
        name: "Interest",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      }
    }
  end

  def plot_data
    yearly_values
  end

  private
    COMPOUNDS_PER_YEAR = 12

    attr_reader :initial_investment, :monthly_contribution, :annual_interest_rate

    def yearly_values
      @yearly_value ||= begin
        total_value = initial_investment
        total_contributed = initial_investment
        result = [ year_zero ]

        1.upto(years_to_grow) do |year|
          1.upto(12) do |month|
            interest = total_value * (annual_interest_rate / COMPOUNDS_PER_YEAR)
            total_value += interest + monthly_contribution
            total_contributed += monthly_contribution
          end

          result << {}.tap do |h|
            h[:year] = year
            h[:date] = Date.today + year.years
            h[:contributed] = total_contributed
            h[:interest] = total_value
            h[:currentTotalValue] = total_value
          end
        end

        result
      end
    end

    def year_zero
      {
        year: 0,
        date: Date.today,
        contributed: initial_investment,
        interest: initial_investment,
        currentTotalValue: initial_investment
      }
    end
end
