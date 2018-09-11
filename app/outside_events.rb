class NoisesInBrush < Event
  title "noises"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship

    @game.active_module == :outside and
      @game.stores[:wood] and
      !@game.stores[:compass]
  end

  def init_scenes
    @scenes = {
      :start => {
        :text => [
          "shuffling noices can be heard just ahead.",
          "shadows dance."
        ],
        :options => {
          :investigate => { :next_scene => { 0.5 => :stuff, 1 => :nothing  }  },
          :ignore_them => { :next_scene => :end  }
        }
      },
      :stuff => {
        :reward => { :wood => 100, :fur => 10 },
        :text => [
          "a bundle of sticks lie near the brush. wrapped in coarse furs.",
          "the night is silent."
        ],
        :options => {
          :head_back => { :next_scene => :end }
        }
      },
      :nothing => {
        :text => [
          "vague shapes move. just out of sight.",
          "the sounds stop."
        ],
        :options => {
          :head_back => { :next_scene => :end }
        }
      }
    }
  end
end


class ShiningLocket < Event
  title "a shining locket"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return true if @game.solo_run? and @game.active_module == :outside

    return false
  end

  def init_scenes
    follows = [
      ["stones jut out the ground. each marked with a name.", "and the insignia."],
      ["a tattered war mantle, caught on a branch.", "the insignia sewn in gold, glistens in starlight."],
      ["frightened footprints make a desperate trail to the campsite.", "these were her's."]
    ]

    @scenes = {
      :start => {
        :text => [
          "the locket flashes violently.",
          "rays of light shoot out.",
          "pointing to shadows in the distance."
        ],
        :options => {
          :follow => { :next_scene => :follow },
          :ignore => { :next_scene => :end  }
        }
      },
      :follow => {
        :text => [],
        :cost => { :cured_meat => 1 },
        :options => {
          :go_home => { :next_scene => :end }
        }
      }
    }

    if(roll < 0.25)
      @scenes[:follow][:text] = ["a shattered wanderer contraption.", "not sure what it used to be."]
      @scenes[:follow][:reward] = { :alien_alloy => 1 }
    else
      @scenes[:follow][:text] = follows.sample
    end
  end
end

class RuinedTraps < Event
  title "a ruined trap"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship

    @game.active_module == :outside and
      (@game.buildings[:trap] || 0) > 0
  end

  def init_scenes
    wrecked_traps = (roll * @game.buildings[:trap]).floor + 1

    wrecked_traps = 4 if wrecked_traps > 4
    wrecked_traps = 1 if @game.solo_run?

    @game.buildings[:trap] -= wrecked_traps
    @scenes = {
      :start => {
        :text => [
          "some of the traps have been torn apart.",
          "large prints lead away, into the forest."
        ],
        :options => {
          :track_them => { :next_scene => { 0.3 => :nothing, 1 => :catch  }  },
          :ignore_them => { :next_scene => :end  }
        }
      },
      :nothing => {
        :text => [
          "the tracks disappear after just a few minutes.",
          "the forest is silent."
        ],
        :options => {
          :go_home => { :next_scene => :end }
        }
      },
      :catch => {
        :text => [
          "not far from the village lies a large beast, its fur matted with blood.",
          "it puts up little resistance before the knife."
        ],
        :reward => { :meat => 100, :fur => 100, :teeth => 10 },
        :options => {
          :go_home => { :next_scene => :end }
        }
      }
    }
  end
end

class BeastAttack < Event
  title "a beast attack"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.solo_run?
    return false if @game.active_module == :ship

    @game.active_module == :outside and (@game.outside.population || 0) > 0
  end

  def init_scenes
    killed_population = (roll * 10).floor + 1

    @game.outside.kill_population(killed_population)

    @scenes = {
      :start => {
        :text => [
          "a pack of snarling beasts pours out of the trees.",
        ],
        :options => {
          :continue => { :next_scene => :continue  },
        }
      },
      :continue => {
        :text => [
          "the fight is short and bloody. the beasts are repelled.",
          "the villagers retreat to mourn the dead."
        ],
        :reward => { :meat => 100, :fur => 100, :teeth => 10 },
        :options => {
          :go_home => { :next_scene => :end }
        }
      }
    }
  end
end

class SoldierAttack < Event
  title "a military raid"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.solo_run?
    return false if @game.active_module == :ship
    return false if !@game.stores[:compass]

    @game.active_module == :outside and @game.outside.population > 40
  end

  def init_scenes
    killed_population = (roll * 40).floor + 1

    @game.outside.kill_population(killed_population)

    @scenes = {
      :start => {
        :text => [
          'a gunshot rings through the trees.',
          'well armed men charge out of the forest. firing into the crowd.',
        ],
        :options => {
          :continue => { :next_scene => :continue  },
        }
      },
      :continue => {
        :text => [
          'after a skirmish they are driven away. but not without losses.'
        ],
        :reward => { :bullets => 10, :cured_meat => 50 },
        :options => {
          :go_home => { :next_scene => :end }
        }
      }
    }
  end
end
