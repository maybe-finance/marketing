class Tool::LoanCalculator < Tool::Presenter
  def initialize(**options)
    @loan_amount = extract_float_option(options, :loan_amount)
    @interest_rate = extract_float_option(options, :interest_rate)
    @loan_term = extract_integer_option(options, :loan_term)
    @loan_period = options[:loan_period].presence_in(%w[ years months ]) || "years"
    @date = Date.parse(options[:date].presence || Date.current.to_s)
  end

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
    attr_reader :loan_amount, :interest_rate, :loan_term, :loan_period, :date

    def active_record
      @active_record ||= Tool.find_by! slug: "loan-calculator"
    end

    def monthly_interest_rate
      interest_rate / 100 / 12
    end
end
