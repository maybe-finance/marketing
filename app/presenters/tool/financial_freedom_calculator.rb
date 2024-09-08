class Tool::FinancialFreedomCalculator < Tool::Presenter
  def initialize(_, **options)
    super

    @current_savings = (options[:current_savings].presence || 0).to_d
    @monthly_expenses = (options[:monthly_expenses].presence || 0).to_d
    @annual_savings_growth_rate = (options[:annual_savings_growth_rate].presence || 0).to_d / 100
  end

  def blank?
    [ current_savings, monthly_expenses, annual_savings_growth_rate ].all?(&:zero?)
  end

  def free_forever?
    current_savings * monthly_savings_growth_rate >= monthly_expenses
  end

  def series_data
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
    DAYS_IN_A_MONTH = 365.25 / 12
    SECONDS_IN_A_DAY = 60 * 60 * 24

    attr_reader :source, :current_savings, :monthly_expenses, :annual_savings_growth_rate

    def monthly_savings_growth_rate
      annual_savings_growth_rate / 12
    end

    def monthly_savings
      @monthly_savings ||= begin
        result = [ current_savings ]
        savings = current_savings

        while savings > 0
          break if savings > current_savings || result.size > 1_000 # guard against malicious input
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
