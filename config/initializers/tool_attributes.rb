class ToolFloat < ActiveModel::Type::Float
  def initialize(min: nil, max: nil, **rest)
    @min = min
    @max = max
    super(**rest)
  end

  def cast(value)
    value = value.to_s.gsub(/[^\d.-]/, "") # Remove non-numeric characters added by autonumeric
    value = super(value)

    if @min && value < @min
      raise ArgumentError, "Value must be greater than or equal to #{@min}"
    end

    if @max && value > @max
      raise ArgumentError, "Value must be less than or equal to #{@max}"
    end

    value
  end
end

class ToolInteger < ToolFloat
  def cast(value)
    super(value).to_i
  end
end

class ToolPercentage < ToolFloat
  def cast(value)
    value = super(value)

    unless value.nil?
      value / 100.0
    end
  end
end

class ToolEnum < ActiveModel::Type::ImmutableString
  def initialize(enum:, **rest)
    @enum = enum.index_by(&:itself)
    super(**rest)
  end

  def cast(value)
    value = @enum[value].presence
    super(value)
  end
end

class ToolArray < ActiveModel::Type::Value
  def initialize(type:, max: nil, **rest)
    @type = type
    @max = max
    super(**rest)
  end

  def cast(value)
    if @max && value.size > @max
      raise ArgumentError, "Value must have at most #{@max} elements"
    end

    value = @type == :percentage ? value.map { |v| ToolPercentage.new.cast(v) } : value
    super(value)
  end
end

class ToolString < ActiveModel::Type::String
  def initialize(enum: nil, **rest)
    @enum = enum&.index_by(&:itself)
    super(**rest)
  end

  def cast(value)
    value = @enum[value].presence if @enum
    super(value)
  end
end

ActiveModel::Type.register :tool_float, ToolFloat
ActiveModel::Type.register :tool_integer, ToolInteger
ActiveModel::Type.register :tool_percentage, ToolPercentage
ActiveModel::Type.register :tool_enum, ToolEnum
ActiveModel::Type.register :tool_array, ToolArray
ActiveModel::Type.register :tool_string, ToolString
