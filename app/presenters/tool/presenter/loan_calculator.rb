class Tool::Presenter::LoanCalculator < Tool::Presenter
  attribute :loan_amount, :tool_float, default: 25000.0
  attribute :interest_rate, :tool_percentage, default: 5.5
  attribute :loan_term, :tool_integer, default: 5
  attribute :loan_period, :tool_enum, enum: %w[ years months ], default: "years"
  attribute :date, :date, default: -> { Date.today }

  def blank?
    [ loan_amount, interest_rate, loan_term ].all?(&:zero?)
  end

  def monthly_payments
    pv = loan_amount
    r = monthly_interest_rate
    n = total_number_of_payments

    (r * pv) / (1 - (1 + r)**-n)
  end

  def total_principal_paid
    loan_amount
  end

  def total_interest_paid
    total_paid - loan_amount
  end

  def total_paid
    monthly_payments * total_number_of_payments
  end

  def total_number_of_payments
    case loan_period
    when "years"
      loan_term * 12
    when "months"
      loan_term
    end.clamp(1, 500) # guard against malicious input
  end

  def estimated_payoff_date
    date + total_number_of_payments.months
  end

  private
    def active_record
      @active_record ||= Tool.find_by! slug: "loan-calculator"
    end

    def monthly_interest_rate
      interest_rate / 12.0
    end
end
