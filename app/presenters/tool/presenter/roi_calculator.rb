class Tool::Presenter::RoiCalculator < Tool::Presenter
  attribute :amount_invested, :tool_float, default: 10000.0
  attribute :amount_returned, :tool_float, default: 12500.0
  attribute :investment_length, :tool_float, default: 3.0

  attribute :investment_period, :tool_enum, enum: %w[ years weeks days ], default: "years"

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
    (roi / investment_length_in_years).round(2)
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

    def active_record
      @active_record ||= Tool.find_by! slug: "roi-calculator"
    end

    def investment_length_in_years
      case investment_period
      when "years"
        investment_length
      when "weeks"
        investment_length / WEEKS_IN_YEAR
      when "days"
        investment_length / DAYS_IN_YEAR
      end
    end
end
