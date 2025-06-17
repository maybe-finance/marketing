class Tool::Presenter::RetirementCalculator < Tool::Presenter
  attribute :retirement_age, :tool_integer, default: 65, max: 100
  attribute :current_age, :tool_integer, default: 30, min: 0

  attribute :annual_salary, :tool_float, default: 75000.0
  attribute :current_401k_balance, :tool_float, default: 25000.0

  attribute :annual_rate_of_return, :tool_percentage, default: 5.0
  attribute :monthly_contribution, :tool_percentage, default: 6.0
  attribute :annual_salary_increase, :tool_percentage, default: 3.0
  attribute :employer_match, :tool_percentage, default: 50.0
  attribute :salary_limit_match, :tool_percentage, default: 6.0

  def blank?
    [ annual_salary, monthly_contribution, annual_salary_increase,
      current_age, current_401k_balance, employer_match, salary_limit_match ].all?(&:zero?)
  end

  def current_total_value
    plot_data.last[:currentTotalValue].round(2)
  end

  def total_employee_contributions
    plot_data.last[:totalEmployeeContributions].round(2)
  end

  def total_employer_contributions
    plot_data.last[:totalEmployerContributions].round(2)
  end

  def legend_data
    {
      contributed: {
        name: "Without employer match",
        fillClass: "fill-violet-600",
        strokeClass: "stroke-violet-600"
      },
      interest: {
        name: "With employer match",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      }
    }
  end

  def plot_data
    yearly_data_points
  end

  private
    COMPOUNDS_PER_YEAR = 12

    def active_record
      @active_record ||= Tool.find_by! slug: "401k-retirement-calculator"
    end

    def years_to_retirement
      retirement_age - current_age
    end

    def monthly_rate_of_return
      annual_rate_of_return / 12.0
    end

    def yearly_data_points
      @yearly_data_points ||= begin
        employee_contribution_total = 0
        employer_contribution_total = 0
        retirement_amount = current_401k_balance
        result = []

        (0...years_to_retirement).each do |year|
          effective_salary = annual_salary * (1 + annual_salary_increase)**year
          employee_contribution = effective_salary * monthly_contribution
          employer_contribution = [ employee_contribution, effective_salary * salary_limit_match ].min * employer_match
          annual_contribution = employee_contribution + employer_contribution

          employee_contribution_total += employee_contribution
          employer_contribution_total += employer_contribution

          12.times do
            retirement_amount = (retirement_amount + annual_contribution / COMPOUNDS_PER_YEAR) * (1 + monthly_rate_of_return)
          end

          result << {}.tap do |h|
            h[:year] = year + 1
            h[:date] = Date.today + (year + 1).years
            h[:contributed] = employee_contribution_total
            h[:interest] = employee_contribution_total + employer_contribution_total
            h[:currentTotalValue] = retirement_amount
            h[:totalEmployeeContributions] = employee_contribution_total
            h[:totalEmployerContributions] = employer_contribution_total
          end
        end

        result
      end
    end
end
