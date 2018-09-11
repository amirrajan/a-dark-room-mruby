class Craft
  def buyable?
    true
  end

  def initialize buildings
    @buildings = buildings
  end

  def half_wood_cost
    (cost[:wood] || 0) / 2
  end

  def unlocks_workers?
    false
  end

  def cost
    { :wood => 0 }
  end

  def fund stores
    cost.keys.each do |key|
      stores[key] ||= 0
      stores[key] += cost[key]
    end
  end

  def maximum
    1
  end

  def requires_hut?
    false
  end
end

class Trap < Craft
  def cost
    trap_count = @buildings[:trap] || 0

    { :wood => 10 + (trap_count * 5) }
  end

  def build_message
    "more traps to catch more creatures."
  end

  def builder_message
    "builder says she can make traps to catch creatures."
  end

  def maximum
    30
  end
end

class Cart < Craft
  def cost
    { :wood => 10 }
  end

  def build_message
    "the rickety cart will carry more wood, faster."
  end

  def builder_message
    "builder says she can make a cart for carrying wood."
  end
end

class Hut < Craft
  def cost
    hut_count = @buildings[:hut] || 0

    { :wood => 80 + (hut_count * 60) }
  end

  def build_message
    "builder puts up a hut, out in the forest. says word will get around."
  end

  def builder_message
    "builder says there are more wanderers. says they'll work, too."
  end

  def unlocks_workers?
    true
  end

  def workers
    [:gatherer]
  end

  def maximum
    20
  end
end

class Lodge < Craft
  def cost
    { :wood => 100, :fur => 10, :meat => 5 }
  end

  def build_message
    "the hunting lodge stands in the forest, a ways out of town."
  end

  def builder_message
    "villagers could help hunt, given the means."
  end

  def unlocks_workers?
    true
  end

  def requires_hut?
    true
  end

  def workers
    [:hunter, :trapper]
  end
end

class Tradepost < Craft
  def cost
    {
      :wood => 300,
      :fur => 100
    }
  end

  def build_message
    "now the nomads have a place to set up shop, they might stick around a while."
  end

  def builder_message
    "a trading post would make commerce easier."
  end
end

class Tannery < Craft
  def cost
    {
      :wood => 500,
      :fur => 50
    }
  end

  def build_message
    "tannery goes up quick, on the edge of the village."
  end

  def builder_message
    "leather could be useful. says the villagers could make it."
  end

  def requires_hut?
    true
  end

  def unlocks_workers?
    true
  end

  def workers
    [:tanner]
  end
end

class Smokehouse < Craft
  def cost
    {
      :wood => 600,
      :meat => 50
    }
  end

  def build_message
    "builder finishes the smokehouse. her reluctance shows."
  end

  def builder_message
    "cure meat, or it'll spoil. builder says she can help prepare."
  end

  def requires_hut?
    true
  end

  def unlocks_workers?
    true
  end

  def workers
    [:charcutier]
  end
end

class Workshop < Craft
  def cost
    {
      :wood => 400,
      :leather => 15,
      :scales => 10
    }
  end

  def builder_message
    "with reluctance in her voice, builder says she could make things to help with the journey."
  end

  def build_message
    "workshop's finally ready."
  end
end

class Steelworks < Craft
  def cost
    {
      :wood => 800,
      :iron => 100,
      :coal => 100
    }
  end

  def builder_message
    "builder says the villagers could make steel, given the tools."
  end

  def requires_hut?
    true
  end

  def unlocks_workers?
    true
  end

  def workers
    [:steelworker]
  end

  def build_message
    "a dark haze falls over the village as the steelworks fires up."
  end
end

class Armoury < Craft
  def cost
    {
      :wood => 1600,
      :steel => 100,
      :sulphur => 50
    }
  end

  def builder_message
    "an armoury can be made. will force her to build it."
  end

  def build_message
    "armoury's done. a dark age sets in she says."
  end

  def requires_hut?
    true
  end

  def unlocks_workers?
    true
  end

  def workers
    [:armourer]
  end
end

#smelly
class Mine < Craft
  def unlocks_workers?
    true
  end

  def requires_hut?
    true
  end

  def buyable?
    false
  end

  def builder_message
    ""
  end

  def build_message
    ""
  end
end

class IronMine < Mine
  def workers
    [:iron_miner]
  end
end

class CoalMine < Mine
  def workers
    [:coal_miner]
  end
end

class SulphurMine < Mine
  def workers
    [:sulphur_miner]
  end
end
