class Tool
  def half_wood_cost
    (cost[:wood] || 0) / 2
  end

  def maximum
    9001 #it's over 9000!!!?!?
  end

  def meets_prerequisite? available_tools
    true
  end
end


############################
#Level 1
############################
class BoneSpear < Tool
  def cost
    { :wood => 100, :teeth => 5 }
  end

  def build_message
    "this spear's not elegant, but it's pretty good at stabbing."
  end
end

class Torch < Tool
  def cost
    { :wood => 1, :cloth => 1 }
  end

  def build_message
    "a torch to keep the dark away."
  end
end

class Waterskin < Tool
  def cost
    { :leather => 15 }
  end

  def build_message
    "this waterskin'll hold a bit of water, at least."
  end

  def maximum
    1
  end
end

class Rucksack < Tool
  def cost
    { :leather => 200 }
  end

  def build_message
    "carrying more means longer expeditions to the wilds."
  end

  def maximum
    1
  end
end

class LeatherArmour < Tool
  def cost
    { :leather => 200, :scales => 20 }
  end

  def build_message
    "leather's not strong. better than rags, though."
  end

  def maximum
    1
  end
end


############################
#Level 2
############################
class ToolLevel2 < Tool
  def meets_prerequisite? available_tools
    available_tools[:bone_spear] and
      available_tools[:torch] and
      available_tools[:waterskin] and
      available_tools[:rucksack] and
      available_tools[:leather_armour]
  end
end

class IronSword < ToolLevel2
  def cost
    { :wood => 200, :leather => 50, :iron => 20 }
  end

  def build_message
    "sword is sharp. good protection out in the wilds."
  end
end

class Cask < ToolLevel2
  def cost
    { :leather => 30, :iron => 20 }
  end

  def build_message
    "the cask holds enough water for longer expeditions."
  end

  def maximum
    1
  end
end

class Wagon < ToolLevel2
  def cost
    { :wood => 200, :iron => 50 }
  end

  def build_message
    "the wagon can carry a lot of supplies."
  end

  def maximum
    1
  end
end

class IronArmour < ToolLevel2
  def cost
    { :leather => 30, :iron => 100 }
  end

  def build_message
    "iron's stronger than leather."
  end

  def maximum
    1
  end
end



############################
#Level 3
############################
class ToolLevel3 < Tool
  def meets_prerequisite? available_tools
    available_tools[:iron_sword] and
      available_tools[:cask] and
      available_tools[:wagon] and
      available_tools[:iron_armour]
  end
end

class WaterTank < ToolLevel3
  def cost
    { :iron => 100, :steel => 50 }
  end

  def build_message
    "never go thirsty again."
  end

  def maximum
    1
  end
end

class Convoy < ToolLevel3
  def cost
    { :wood => 1000, :iron => 200, :steel => 100 }
  end

  def build_message
    "the convoy can haul mostly everything."
  end

  def maximum
    1
  end
end

class SteelArmour < ToolLevel3
  def cost
    { :leather => 200, :steel => 100 }
  end

  def build_message
    "steel's stronger than iron."
  end

  def maximum
    1
  end
end

class SteelSword < ToolLevel3
  def cost
    { :wood => 500, :leather => 100, :steel => 20 }
  end

  def build_message
    "the steel is strong, and the blade is true."
  end
end

class Rifle < ToolLevel3
  def cost
    { :wood => 200, :steel => 50, :sulphur => 50 }
  end

  def build_message
    "black powder and bullets. nothing changes."
  end
end

############################
#Level 4
############################
class ToolLevel4 < Tool
  def meets_prerequisite? available_tools
    available_tools[:steel_sword] and
      available_tools[:water_tank] and
      available_tools[:convoy] and
      available_tools[:steel_armour] and
      available_tools[:rifle]
  end
end

class WarMantle < ToolLevel4
  def cost
    { :leather => 300, :alien_alloy => 5, :jewel => 1 }
  end

  def build_message
    "a warrior once more."
  end

  def maximum
    1
  end
end
