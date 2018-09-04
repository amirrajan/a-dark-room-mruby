class CostString
  def to_s stores, times = 1
    stores.keys.each do |key|
      stores[key] = stores[key] * times
    end

    stores.keys.map do |material|
      "#{format_number stores[material]} #{material.gsub("_", " ")}"
    end.join(", ")
  end

  def format_number number
    return number.to_s if number < 2000 or number % 10 != 0

    k = number.to_f / 1000.0

    return "#{k}k" if k != k.to_i

    "#{k.to_i}k"
  end

  def difference cost, stores, times = 1
    result = { }
    cost.keys.each do |key|
      diff = (cost[key] * times) - (stores[key] || 0)
      result[key] = diff if diff > 0
    end

    to_s(result)
  end
end
