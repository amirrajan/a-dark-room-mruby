class Trade
  def maximum
    9001
  end
end

class Compass < Trade
  def maximum
    1
  end

  def cost
    { :fur => 400, :scales => 20, :teeth => 10 }
  end

  def available_if
    :wood
  end
end

class Bait < Trade
  def cost
    { :meat => 5 }
  end

  def available_if
    :wood
  end
end

class Scales < Trade
  def cost
    { :fur => 30 }
  end

  def available_if
    :scales
  end
end

class Teeth < Trade
  def cost
    { :fur => 30 }
  end

  def available_if
    :teeth
  end
end

class CuredMeat < Trade
  def cost
    { :meat => 30 }
  end

  def available_if
    :cured_meat
  end
end

class Leather < Trade
  def cost
    { :fur => 25 }
  end

  def available_if
    :leather
  end
end

class Iron < Trade
  def cost
    { :fur => 30, :scales => 5 }
  end

  def available_if
    :iron
  end
end

class Steel < Trade
  def cost
    { :fur => 30, :scales => 5, :teeth => 5 }
  end

  def available_if
    :steel
  end
end

class Coal < Trade
  def cost
    { :fur => 30, :teeth => 5 }
  end

  def available_if
    :coal
  end
end

class Bullets < Trade
  def cost
    { :scales => 10 }
  end

  def available_if
    :bullets
  end
end

class Battery < Trade
  def cost
    { :scales => 10, :teeth => 10 }
  end

  def available_if
    :battery
  end
end

class Grenade < Trade
  def cost
    { :scales => 15, :teeth => 10 }
  end

  def available_if
    :grenade
  end
end

class Bolas < Trade
  def cost
    { :teeth => 10 }
  end

  def available_if
    :bolas
  end
end

class AlienAlloy < Trade
  def cost
    { :fur => 1000, :scales => 75, :teeth => 30 }
  end

  def available_if
    :alien_alloy
  end
end

class Katana < Trade
  def cost
    { :scales => 50, :teeth => 25 }
  end

  def available_if
    :katana
  end
end
