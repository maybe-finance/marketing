class Tool::RoiCalculator < Tool::Presenter
  def initialize(**options)
    @active_record = Tool.find_by! slug: "roi-calculator"

    @amount_invested = extract_decimal_option(options, :amount_invested)
    @amount_returned = extract_decimal_option(options, :amount_returned)
    @investment_length = extract_decimal_option(options, :investment_length)
    @investment_period = options[:investment_period].presence_in(%w[ years weeks days ]) || "years"
  end

  def blank?
    [ amount_invested, amount_returned, investment_length ].all?(&:zero?)
  end

  def investment_gain
    (amount_returned - amount_invested).round(2)
  end

  def roi
    (investment_gain * 100 / amount_invested).round(2)
  end

  def annualized_roi
    (roi / investment_length).round(2)
  end

  def roi_sign
    "+" if roi >= 0
  end

  def roi_class
    if roi >= 0
      "text-green-500 text-4xl font-medium"
    else
      "text-red-500 text-4xl font-medium"
    end
  end

  def trend_class
    if roi >= 0
      "from-green-50"
    else
      "from-red-50"
    end
  end

  private
    WEEKS_IN_YEAR = 52.1775
    DAYS_IN_YEAR = 365.25

    attr_reader :amount_invested, :amount_returned, :investment_period

    def investment_length
      case investment_period
      when "years"
        @investment_length
      when "weeks"
        @investment_length / WEEKS_IN_YEAR
      when "days"
        @investment_length / DAYS_IN_YEAR
      end
    end
end
