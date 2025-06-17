class Tool::Presenter::CompoundInterestCalculator < Tool::Presenter
  attribute :annual_interest_rate, :tool_percentage, default: 7.0

  attribute :initial_investment, :tool_float, default: 5000.0
  attribute :monthly_contribution, :tool_float, default: 500.0
  attribute :years_to_grow, :tool_float, default: 20.0, min: 0.0, max: 150.0
  attribute :filter, :string

  def blank?
    [ initial_investment, monthly_contribution, years_to_grow, annual_interest_rate ].all?(&:zero?)
  end

  def total_value
    plot_data.last[:currentTotalValue].round(2)
  end

  def legend_data
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

    def active_record
      @active_record ||= Tool.find_by! slug: "compound-interest-calculator"
    end

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
