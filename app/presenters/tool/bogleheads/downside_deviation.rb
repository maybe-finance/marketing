class Tool::Bogleheads::DownsideDeviation
  def initialize(tool)
    @tool = tool
  end

  def value
    @value ||= Math.sqrt(squared_percentage_returns_below_target.sum / percentage_returns.size).round(2)
  end

  def risk_level
    case value
    when 0..1.23
      "Low"
    when 1.23..2.31
      "Moderate"
    else
      "High"
    end
  end

  private
    DOWNSIDE_DEVIATION_TARGET = 0

    attr_reader :tool

    delegate :plot_data, :invested_amount, to: :tool, private: true

    def squared_percentage_returns_below_target
      percentage_returns.map do |percentage|
        if percentage < DOWNSIDE_DEVIATION_TARGET
          percentage ** 2
        else
          0
        end
      end
    end

    def percentage_returns
      @percentage_returns ||= plot_data.map.with_index do |month, i|
        previous_value = i.zero? ? invested_amount : plot_data[i - 1][:value]

        if (previous_value - 1).zero?
          0
        else
          (month[:value] / previous_value - 1) * 100
        end
      end
    end
end
