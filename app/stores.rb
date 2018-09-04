class Stores < Hash
  def initialize
    @cost_string = CostString.new
  end

  def has? item
    (self[item] || 0) > 0
  end

  def afford? item, amount = 1
    result = true

    item.keys.map do |material|
      difference = (self[material] || 0) - (item[material] * amount)

      result = false if difference < 0
    end

    result
  end

  def increase amounts
    amounts.keys.each do |key|
      self[key] ||= 0
      self[key] += amounts[key]
    end
  end

  def deduct cost
    cost.keys.map do |material|
      self[material] ||= 0
      self[material] -= cost[material]
    end
  end

  def cost_string item
    @cost_string.to_s item
  end
end
