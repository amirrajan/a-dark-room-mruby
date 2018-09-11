class Game
  attr_accessor :workers, :buildings, :stores,
                :room, :history, :outside,
                :events, :active_module, :world,
                :tick_count, :game_state, :perks,
                :cost_string, :ship_thrusters, :ship_hull,
                :lift_off_after, :current_lift_off_ticks, :ship_base_thrusters,
                :fastest_completion_ticks

  def initialize
    @ship_base_thrusters = 2
    @fastest_completion_ticks = 0
    @tick_count = 0
    @ship_thrusters = 1
    @lift_off_after = 90
    @current_lift_off_ticks = 0
    @ship_hull = 1
    @perks = []
    @active_module = :room
    @history = Array.new
    @tick_history = Array.new
    @stores = Stores.new
    @workers = Hash.new
    @buildings = Hash.new
    @room = Room.new @history, @stores, @buildings, @workers, self
    @events = Events.new self
    @events.schedule
    @outside = Outside.new @history, @stores, @buildings, @workers, self
    @world = World.new self
    # @game_state = GameState.new self
    @cost_string = CostString.new
    @last_history_count = 0
  end

  def tick_speed
    0.7 #in seconds
  end

  def completed_once?
    (@fastest_completion_ticks || 0) > 5
  end

  def solo_run?
    @outside.solo_run?
  end

  def slaves?
    return @outside.story_displayed.any? { |s| s.include?("slaves") }
  end

  def builder_gather_rate
    5
  end

  def white_listed_modules
    @white_listed_modules ||= [:room, :outside, :embark]
  end

  def builder_gathers_wood
    return if @stores[:her_locket]
    return if !@room.builder_ready?
    return if (@tick_count % 10) != 0

    @stores[:wood] ||= 0
    @stores[:wood] += builder_gather_rate
  end

  def at_final_stage?
    result = @outside.story_displayed.any? { |s| !s.match(/vanishes/).nil? }
    result = result || builder_flipping_out?

    if result and !@stores[:her_locket] #locket denotes that she is gone
      @stores[:her_locket] = 1
      @stores[:jewel] ||= 0
      @stores[:jewel] += 5
      @buildings[:trap] = 30 #traps so the player isn't screwed
      @room.kill_fire
    end

    result
  end

  def add_perk name
    return if @perks.include? name

    @perks << name

    @history << perks_descriptions[name][:notify]
  end

  def perks_descriptions
    {
      :boxer => { #done
        :desc => 'punches do more damage.',
        :notify => 'learned to throw punches with purpose.'
      },
      :martial_artist => { #done
        :desc => 'punches do even more damage.',
        :notify => 'learned to fight quite effectively without weapons.'
      },
      :unarmed_master => { #done
        :desc => 'punches do devastating damage.',
        :notify => 'mastered striking without weapons.'
      },
      :barbarian => { #done
        :desc => 'melee weapons deal more damage.',
        :notify => 'learned to swing weapons with force.'
      },
      :slow_metabolism => { #done
        :desc => 'go twice as far without eating.',
        :notify => 'learned how to ignore the hunger.'
      },
      :desert_rat => { #done
        :desc => 'go twice as far without drinking.',
        :notify => 'learned to love the dry air.'
      },
      :evasive => { #done
        :desc => 'dodge attacks more effectively.',
        :notify => "learned to be where they're not."
      },
      :precise => { #done
        :desc => 'land blows more often.',
        :notify => 'learned to predict their movement.'
      },
      :scout => { #done
        :desc => 'see farther.',
        :notify => 'learned to look ahead.'
      },
      :stealthy => { #done
        :desc => 'better avoid conflict in the wild.',
        :notify => 'learned how not to be seen.'
      },
      :gastronome => { #done
        :desc => 'restore more health when eating.',
        :notify => 'learned to make the most of food.'
      }
    }
  end

  def builder_flipping_out?
    @outside.story_displayed.any? { |s| s.include?("convulsions") }
  end

  def builder_not_moving?
    @outside.story_displayed.any? { |s| s.include?("she stops moving").nil? }
  end

  def builder_awake?
    @outside.story_displayed.any? { |s| s.include?("she's awake").nil? }
  end

  def builder_at_ship?
    @outside.story_displayed.any? { |s| s.include?("to be taken away").nil? }
  end

  def has_perk? name
    @perks.include? name
  end

  def tick
    @room.tick
    @outside.tick
    @events.tick if(white_listed_modules.include? @active_module)
    # @world.tick
    builder_gathers_wood

    # if @world.ship_cleared?
    #   if @current_lift_off_ticks < @lift_off_after
    #     @current_lift_off_ticks += 1
    #   end
    # end

    @history << "awake. head throbbing. the voices say to survive." if @tick_count == 1

    @tick_count += 1

    # @tick_history.clear
    # difference = @history.count - @last_history_count
    # @tick_history.push(*@history[-(difference)..@history.count]) if difference > 0
    # @last_history_count = @history.count
  end
end
