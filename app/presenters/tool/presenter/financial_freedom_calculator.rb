class Tool::Presenter::FinancialFreedomCalculator < Tool::Presenter
  attribute :annual_savings_growth_rate, :tool_percentage, default: 7.0

  attribute :current_savings, :tool_float, default: 50000.0
  attribute :monthly_expenses, :tool_float, default: 4000.0

  def blank?
    [ current_savings, monthly_expenses, annual_savings_growth_rate ].all?(&:zero?)
  end

  def free_forever?
    current_savings * monthly_savings_growth_rate >= monthly_expenses
  end

  def legend_data
    {
      savingsRemaining: {
        name: "Savings remaining",
        fillClass: "fill-blue-600",
        strokeClass: "stroke-blue-600"
      },
      monthlyExpenditure: {
        name: "Monthly expenses",
        fillClass: "fill-pink-500",
        strokeClass: "stroke-pink-500"
      }
    }
  end

  def plot_data
    monthly_savings.map.with_index do |savings, i|
      {
        date: Date.today + i.months,
        savingsRemaining: [ savings, 0 ].max,
        monthlyExpenditure: monthly_expenses
      }
    end
  end

  def seconds_left
    days_left * SECONDS_IN_A_DAY
  end

  private
    DAYS_IN_A_MONTH = 365.25 / 12.0
    SECONDS_IN_A_DAY = 60 * 60 * 24

    def active_record
      @active_record ||= Tool.find_by! slug: "financial-freedom-calculator"
    end

    def monthly_savings_growth_rate
      annual_savings_growth_rate / 12.0
    end

    def monthly_savings
      @monthly_savings ||= begin
        result = [ current_savings ]
        savings = current_savings

        while savings > 0
          break if savings > current_savings || result.size > 1_200 # guard against malicious input
          savings = savings * (1 + monthly_savings_growth_rate) - monthly_expenses
          result << savings
        end

        result
      end
    end

    def days_left
      monthly_savings.size * DAYS_IN_A_MONTH - days_overdrawn
    end

    def days_overdrawn
      if monthly_savings.last.to_i < 0
        (monthly_savings.last / daily_expenses).abs
      else
        0
      end
    end

    def daily_expenses
      monthly_expenses / DAYS_IN_A_MONTH
    end
end
