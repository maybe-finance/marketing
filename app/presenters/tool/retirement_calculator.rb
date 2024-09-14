class Tool::RetirementCalculator < Tool::Presenter
  def initialize(**options)
    @active_record = Tool.find_by! slug: "retirement-calculator"

    @annual_salary = extract_decimal_option(options, :annual_salary)
    @current_age = extract_decimal_option(options, :current_age)
    @retirement_age = extract_decimal_option(options, :retirement_age)
    @current_401k_balance = extract_decimal_option(options, :current_401k_balance)

    @monthly_contribution = extract_percentage_option(options, :monthly_contribution)
    @annual_salary_increase = extract_percentage_option(options, :annual_salary_increase)
    @annual_rate_of_return = extract_percentage_option(options, :annual_rate_of_return)
    @employer_match = extract_percentage_option(options, :employer_match)
    @salary_limit_match = extract_percentage_option(options, :salary_limit_match)
  end

  def blank?
    [ annual_salary, monthly_contribution, annual_salary_increase,
      current_age, retirement_age, annual_rate_of_return,
      current_401k_balance, employer_match, salary_limit_match ].all?(&:zero?)
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

  def series_data
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

    attr_reader :annual_salary, :monthly_contribution, :annual_salary_increase, :current_age,
      :retirement_age, :annual_rate_of_return, :current_401k_balance, :employer_match, :salary_limit_match

    def years_to_retirement
      retirement_age - current_age
    end

    def monthly_rate_of_return
      annual_rate_of_return / 12
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
            h[:date] = Date.today + year.years
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
