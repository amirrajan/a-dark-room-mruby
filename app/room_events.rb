class TheNomad < Event
  title "the nomad"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship

    @game.active_module == :room and
      @game.stores[:fur] and
      @game.stores[:fur] >= 10
  end

  def init_scenes
    end_buy_text = [
      "the deal is done.",
      "he turns and walks away without saying a word."
    ]

    leave_option = { :leave => { :next_scene => :end } }

    result = {
      :start => {
        :text => [
          "a nomad shuffles into view. laden with makeshift bags bound with rough twine.",
          "won't say from where he came. the prices are good however."
        ],
        :options => {
          :buy_scales => { :next_scene => :buy_scales },
          :buy_teeth => { :next_scene => :buy_teeth },
          :buy_bait => { :next_scene => :buy_bait },
        }
      },
      :buy_bait =>  {
        :text => end_buy_text,
        :cost => { :fur => 10 },
        :reward => { :bait => 100 },
        :options => leave_option
      },
      :buy_scales =>  {
        :text => end_buy_text,
        :cost => { :fur => 20 },
        :reward => { :scales => 10 },
        :options => leave_option
      },
      :buy_teeth =>  {
        :text => end_buy_text,
        :cost => { :fur => 30 },
        :reward => { :teeth => 10 },
        :options => leave_option
      },
      :compass => {
        :text => end_buy_text,
        :cost => { :fur => 300, :scales => 15 },
        :reward => { :compass => 1 },
        :options => leave_option
      }
    }

    if @game.buildings[:tradepost] and !@game.stores[:compass]
      result[:start][:options][:compass] = { :next_scene => :compass }
    end

    result[:start][:options][:turn_away] = { :next_scene => :end }

    @scenes = result
  end
end

class NoisesOutside < Event
  title "noises"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship

    @game.active_module == :room and
      @game.stores[:wood] and
      !@game.stores[:compass]
  end

  def init_scenes
    @scenes = {
      :start => {
        :text => [
          "through the walls, shuffling noises can be heard.",
          "can't tell what they're up to."
        ],
        :options => {
          :investigate => { :next_scene => { 0.5 => :stuff, 1 => :nothing  }  },
          :ignore_them => { :next_scene => :end  }
        }
      },
      :stuff => {
        :reward => { :wood => 100, :fur => 10 },
        :text => [
          "a bundle of sticks lies just beyond the threshold, wrapped in coarse furs.",
          "the night is silent."
        ],
        :options => {
          :go_back_inside => { :next_scene => :end }
        }
      },
      :nothing => {
        :text => [
          "vague shapes move, just out of sight.",
          "the sounds stop."
        ],
        :options => {
          :go_back_inside => { :next_scene => :end }
        }
      }
    }
  end
end

class NoisesInside < Event
  title "noises"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship
    return true if @game.active_module == :room and @game.stores[:wood]

    @game.active_module == :outside and @game.stores[:wood]
  end

  def init_scenes
    leave_option = { :leave => { :next_scene => :end } }

    @scenes = {
      :start => {
        :text => [
          "scratching noises can be heard from the store room.",
          "something\'s in there."
        ],
        :options => {
          :investigate => { :next_scene => { 0.5 => :scales, 0.8 => :teeth, 1.0 => :cloth } },
          :ignore => { :next_scene => :end }
        }
      },
      :scales => {
        :text => ["some wood is missing.", "the ground is littered with small scales."],
        :options => leave_option
      },
      :teeth => {
        :text => ["some wood is missing.", "the ground is littered with small teeth."],
        :options => leave_option
      },
      :cloth => {
        :text => ["some wood is missing.", "the ground is littered with scraps of cloth."],
        :options => leave_option
      },
    }

    wood_cost = (@game.stores[:wood] * 0.1).floor
    wood_cost = 1 if wood_cost == 0
    reward_payout = (wood_cost / 5.0).floor
    reward_payout = 1 if reward_payout == 0

    [:scales, :teeth, :cloth].each do |s|
      @scenes[s][:cost] = { :wood => wood_cost  }
      @scenes[s][:reward] = { s => reward_payout  }
    end
  end
end

class TheBeggar < Event
  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship

    @game.active_module == :room and
      @game.stores[:fur] and
      @game.stores[:fur] >= 50
  end

  def init_scenes
    end_buy_text = [
      "a pile of furs left on the ground."
    ]

    leave_option = { :say_goodbye => { :next_scene => :end } }

    result = {
      :start => {
        :text => [
          "a beggar arrives.",
          "asks for any spare furs to keep him warm at night."
        ],
        :options => {
          :small_donation => { :next_scene => :small_donation },
          :modest_donation => { :next_scene => :modest_donation },
          :deny => { :next_scene => :end },
        }
      },
      :small_donation => {
        :text => end_buy_text,
        :cost => { :fur => 50 },
        :options => {
          :walk_away => { :next_scene => { 0.5 => :scales, 0.8 => :teeth, 1.0 => :cloth } },
        }
      },
      :modest_donation => {
        :text => end_buy_text,
        :cost => { :fur => 100 },
        :options => {
          :walk_away => { :next_scene => { 0.5 => :teeth, 0.8 => :scales, 1.0 => :cloth } },
        }
      },
      :scales => {
        :text => ["the beggar says thanks.", "leaves a pile of small scales behind."],
        :reward => { :scales => 20 },
        :options => leave_option
      },
      :teeth => {
        :text => ["the beggar says thanks.", "leaves a pile of small teeth behind."],
        :reward => { :teeth => 20 },
        :options => leave_option
      },
      :cloth => {
        :text => ["the beggar says thanks.", "leaves some scraps of cloth behind."],
        :reward => { :cloth => 20 },
        :options => leave_option
      }
    }

    @scenes = result
  end
end

class WoodGamble < Event
  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship
    return false if @game.at_final_stage?

    @game.active_module == :room and
      @game.stores[:wood] and
      @game.stores[:wood] >= 100
  end

  def init_scenes
    @scenes = {
      :start => {
        :text => [
          "a wanderer arrives with an empty cart. says if he leaves with wood, he'll be back with more.",
          "builder's not sure he's to be trusted."
        ],
        :options => {
          :small_gamble => { :next_scene => :small_gamble },
          :big_gamble => { :next_scene => :big_gamble },
          :turn_him_away => { :next_scene => :end },
        }
      },
      :small_gamble => {
        :cost => { :wood => 100 }
      },
      :big_gamble => {
        :cost => { :wood => 500 }
      }
    }

    small_gamble_reward = 0
    small_gamble_reward = 300 if roll < 0.8

    if small_gamble_reward == 0
      @scenes[:small_gamble][:text] = [
        "waiting with patience.",
        "the wanderer doesn't return."
      ]
      @scenes[:small_gamble][:options] = { :leave_empty_handed => { :next_scene => :end } }
    else
      @scenes[:small_gamble][:text] = [
        "the wanderer returns.",
        "cart piled high with wood.",
      ]
      @scenes[:small_gamble][:reward] = { :wood => 300 }
      @scenes[:small_gamble][:options] = { :thank_wanderer => { :next_scene => :end } }
    end

    big_gamble_reward = 0
    big_gamble_reward = 1500 if roll < 0.2

    if big_gamble_reward == 0
      @scenes[:big_gamble][:text] = [
        "waiting with patience.",
        "the wanderer doesn't return."
      ]
      @scenes[:big_gamble][:options] = { :leave_empty_handed => { :next_scene => :end } }
    else
      @scenes[:big_gamble][:text] = [
        "the wanderer returns.",
        "cart piled high with wood.",
      ]
      @scenes[:big_gamble][:reward] = { :wood => 1500 }
      @scenes[:big_gamble][:options] = { :thank_wanderer => { :next_scene => :end } }
    end
  end
end

class FurGamble < Event
  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :ship
    return false if @game.at_final_stage?

    @game.active_module == :room and
      @game.stores[:fur] and
      @game.stores[:fur] >= 100
  end

  def init_scenes
    @scenes = {
      :start => {
        :text => [
          "a wanderer arrives with an empty cart. says if she leaves with furs, she'll be back with more.",
          "builder's not sure she's to be trusted."
        ],
        :options => {
          :small_gamble => { :next_scene => :small_gamble },
          :big_gamble => { :next_scene => :big_gamble },
          :turn_her_away => { :next_scene => :end },
        }
      },
      :small_gamble => {
        :cost => { :fur => 100 }
      },
      :big_gamble => {
        :cost => { :fur => 500 }
      }
    }

    small_gamble_reward = 0
    small_gamble_reward = 300 if roll < 0.8

    if small_gamble_reward == 0
      @scenes[:small_gamble][:text] = [
        "waiting with patience.",
        "the wanderer doesn't return."
      ]
      @scenes[:small_gamble][:options] = { :leave_empty_handed => { :next_scene => :end } }
    else
      @scenes[:small_gamble][:text] = [
        "the wanderer returns.",
        "cart piled high with fur.",
      ]
      @scenes[:small_gamble][:reward] = { :fur => 300 }
      @scenes[:small_gamble][:options] = { :thank_wanderer => { :next_scene => :end } }
    end

    big_gamble_reward = 0
    big_gamble_reward = 1500 if roll < 0.2

    if big_gamble_reward == 0
      @scenes[:big_gamble][:text] = [
        "waiting with patience.",
        "the wanderer doesn't return."
      ]
      @scenes[:big_gamble][:options] = { :leave_empty_handed => { :next_scene => :end } }
    else
      @scenes[:big_gamble][:text] = [
        "the wanderer returns.",
        "cart piled high with fur.",
      ]
      @scenes[:big_gamble][:reward] = { :fur => 1500 }
      @scenes[:big_gamble][:options] = { :thank_wanderer => { :next_scene => :end } }
    end
  end
end

class TheThief < Event
  title "the thief"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.solo_run?
    return false if !@game.outside.has_population?
    return false if @game.active_module == :ship
    return false if @game.active_module == :world
    return false if !@game.outside.thieves?

    thieves_stores = @game.outside.thieves_stores

    return (thieves_stores[:wood] || 0) > 500 ||
           (thieves_stores[:fur] || 0) > 500 ||
           (thieves_stores[:meat] || 0) > 500
  end

  def init_scenes
    leave_option = { :leave => { :next_scene => :end } }

    result = {
      :start => {
        :text => [
          'the villagers haul a filthy man out of the store room.',
          "say his folk have been skimming the supplies.",
          'say he should be strung up as an example.'
        ],
        :options => {
          :kill_him => { :next_scene => :kill_him },
          :forgive_him => { :next_scene => :forgive_him },
        }
      },
      :kill_him => {
        :text => [
          'the villagers hang the thief high in front of the store room.',
          'the point is made. in the next few days, the missing supplies are returned.'
        ],
        :reward_proc => lambda do
          @history << "received: #{string_for(@game.outside.thieves_stores)}"
          @game.outside.kill_thieves
        end,
        :options => leave_option
      },
      :forgive_him => {
        :text => [
          "the man says he's grateful. says he won't come around any more.",
          "shares what he knows about sneaking before he goes."
        ],
        :reward_proc => lambda do
          @game.outside.forgive_thieves
        end,
        :options => leave_option
      },
    }

    @scenes = result
  end
end
