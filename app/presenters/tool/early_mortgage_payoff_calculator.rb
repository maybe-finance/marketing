class Tool::EarlyMortgagePayoffCalculator < Tool::Presenter
  attribute :loan_amount, :tool_float, default: 0.0, min: 0.0, max: 1_000_000.0
  attribute :extra_payment, :tool_float, default: 0.0

  attribute :interest_rate, :tool_percentage, default: 0.0
  attribute :savings_rate, :tool_percentage, default: 0.0

  attribute :original_term, :tool_integer, default: 0
  attribute :years_left, :tool_integer, default: 0

  def blank?
    [ loan_amount, original_term, years_left, interest_rate, extra_payment, savings_rate ].all?(&:zero?)
  end

  def mortgage_rate_30
    Tool::HomeAffordabilityCalculator.new.mortgage_rate_30
  end

  def interest_savings
    total_interest - total_interest_with_extra_payments
  end

  def total_interest
    @total_interest ||= begin
      result = 0
      balance = loan_amount

      total_payments.times do
        interest_payment = balance * monthly_rate
        result = result + interest_payment
        balance = balance - (regular_payment - interest_payment)
      end

      result
    end
  end

  def total_interest_with_extra_payments
    @total_interest_with_extra_payments ||= begin
      @months_to_payoff_with_extra_payments = 0
      result = 0
      balance = loan_amount

      while balance > 0
        @months_to_payoff_with_extra_payments += 1

        interest_payment = balance * monthly_rate
        principal_payment = regular_payment - interest_payment
        result = result + interest_payment
        balance = balance - principal_payment - extra_payment
      end

      result
    end
  end

  def total_principal_and_interest
    loan_amount + total_interest
  end

  def total_principal_and_interest_with_extra_payments
    loan_amount + total_interest_with_extra_payments
  end

  def original_payoff_date
    Date.today + total_payments.months
  end

  def new_payoff_date
    Date.today + months_to_payoff_with_extra_payments.months
  end

  def savings_account_balance
    @savings_account_balance ||= begin
      result = 0

      months_to_payoff_with_extra_payments.times do
        result = result + extra_payment
        result = result * (1 + savings_rate / 12.0)
      end

      result
    end
  end

  def net_difference
    @net_difference ||= savings_account_balance - interest_savings
  end

  def time_saved
    "#{months_saved / 12} years, #{months_saved % 12} months"
  end

  def net_difference_class
    if net_difference > 0
      "text-green-600"
    elsif net_difference < 0
      "text-red-600"
    end
  end

  def net_difference_comment
    if net_difference > 0
      "Investing the extra payments could potentially yield better returns than paying off the mortgage early."
    elsif net_difference < 0
      "Paying off the mortgage early could potentially save you more money than investing the extra payments."
    else
      "The financial outcome is roughly the same whether you pay off the mortgage early or invest the extra payments."
    end
  end

  def net_difference_comment_class
    if net_difference > 0
      "text-green-600"
    elsif net_difference < 0
      "text-red-600"
    else
      "text-gray-600"
    end
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "early-mortgage-payoff-calculator"
    end

    def monthly_rate
      interest_rate / 12.0
    end

    def total_payments
      years_left * 12
    end

    def regular_payment
      @regular_payment ||= begin
        fv = loan_amount
        r = monthly_rate
        n = total_payments

        (fv * r * (1 + r)**n) / ((1 + r)**n - 1)
      end
    end

    def months_to_payoff_with_extra_payments
      unless defined?(@months_to_payoff_with_extra_payments)
        total_interest_with_extra_payments # set ivar as a side effect
      end

      @months_to_payoff_with_extra_payments
    end

    def months_saved
      total_payments - months_to_payoff_with_extra_payments
    end
end
