class Outside
  include Debugging

  attr_accessor :population, :current_gather_wood_ticks, :roll_override,
                :current_check_traps_ticks, :story_displayed, :thieves, :thieves_stores,
                :thieves_gone


  def initialize history, stores, buildings, workers, game
    @game = game
    @thieves_gone = false
    @gather_wood_count = 0
    @population = 0
    @history = history
    @stores = stores
    @buildings = buildings
    @workers = workers
    @thieves_stores = {}
    @story_displayed = []

    @current_gather_wood_ticks = 60

    @check_traps_after = 45
    @current_check_traps_ticks = 45

    @increase_population_after = 0
    @current_increase_population_ticks = 0

    @income = {
      :gatherer => Gatherer.new,
      :hunter => Hunter.new,
      :trapper => Trapper.new,
      :tanner => Tanner.new,
      :charcutier => Charcutier.new,
      :steelworker => Steelworker.new,
      :armourer => Armourer.new,
      :iron_miner => IronMiner.new,
      :coal_miner => CoalMiner.new,
      :sulphur_miner => SulphurMiner.new,
      :thieves => Thieves.new
    }

    schedule_next_population_increase
  end

  def baited_traps?
    bait_count > trap_count * 2 and trap_count != 0
  end

  def trap_count
    @buildings[:trap] || 0
  end

  def bait_count
    @stores[:bait] || 0
  end

  def can_check_traps?
    @check_traps_after == @current_check_traps_ticks
  end

  def check_traps_after
    @check_traps_after
  end

  def trap_drops
    {
      :fur => { :roll_under => 0.5, :message => 'scraps of fur' },
      :meat => { :roll_under => 0.65, :message => 'bits of meat' },
      :scales => { :roll_under => 0.75, :message => 'strange scales' },
      :teeth => { :roll_under => 0.90, :message => 'scattered teeth' },
      :cloth => { :roll_under => 0.98, :message => 'tattered cloth' },
      :jewel => { :roll_under => 1.0, :message => 'crudely made jewels' }
    }
  end

  def trap_spoils
    spoils = Hash.new

    drop_count = trap_count * 2

    bait_used = baited_traps?

    drop_count = bait_count if bait_used

    drop_count.times do
      the_roll = roll

      drop_logged = false
      trap_drops.keys.each do |key|
        drop = trap_drops[key]
        if roll < drop[:roll_under] and !drop_logged
          spoils[key] ||= 0
          spoils[key] += 1 * multiplier
          spoils[key] += 1 if bait_used
          drop_logged = true
        end
      end
    end

    @stores[:bait] = 0 if bait_used

    spoils
  end

  def check_traps
    return false if !can_check_traps?

    if trap_count == 0
      @history << "the traps. they've all been destroyed."
      return
    end

    bait_used = baited_traps?

    last_bait_count = bait_count

    spoils = trap_spoils

    spoils.keys.map do |key|
      @stores[key] ||= 0

      @stores[key] += spoils[key]
    end

    spoils_message = spoils.keys.map { |key| spoils[key].to_s + " " + trap_drops[key][:message] }.join ", "

    quantity = trap_count
    message = "#{quantity} traps contained: " + spoils_message + "."

    if bait_used
      quantity = last_bait_count
      message = "#{quantity} baited traps contained: " + spoils_message + "."
    end

    message = "traps contained nothing." if spoils.keys.count == 0

    @history << message

    @current_check_traps_ticks = 0

    true
  end

  def title
    return "a silent forest" if hut_count == 0

    return "a lonely hut" if hut_count == 1

    return "a tiny village" if hut_count <= 4

    return "a modest village" if hut_count <= 8

    return "a large village" if hut_count <= 14

    "a raucous village"
  end

  def max_population
    hut_count * 4
  end

  def wandering_group
    group = ((roll * space_left.to_f / 2.0) + (space_left.to_f / 2.0)).floor

    return 1 if group == 0

    group
  end

  def space_left
    max_population - @population
  end

  def schedule_next_population_increase
    @increase_population_after = ((roll * (2.0 - 0.5) + 0.5).floor * 60) + 60
  end

  def can_gather_wood?
    @current_gather_wood_ticks >= gather_wood_after
  end

  def has_cart?
    @buildings[:cart] == 1
  end

  def gather_wood_after
    return 20 if has_cart?

    30
  end
  def tick_thieves
    return if !has? :compass
    return if thieves_gone
    return if thieves?
    return if no_huts?
    return if hut_count < 10

    if @stores.keys.any? { |k| @stores[k] >= 2000 }
      start_thieves
    end
  end

  def forgive_thieves
    return if !remove_thieves

    @thieves_gone = true

    @game.add_perk :stealthy
  end

  def remove_thieves
    return false if @thieves_gone
    @thieves_gone = true
    true
  end

  def kill_thieves
    return if !remove_thieves

    @stores[:wood] += @thieves_stores[:wood]
    @stores[:fur] += @thieves_stores[:fur]
    @stores[:meat] += @thieves_stores[:meat]
  end

  def start_thieves
    @thieves_stores[:wood] = 0
    @thieves_stores[:fur] = 0
    @thieves_stores[:meat] = 0
  end

  def gather_wood
    return if !can_gather_wood?

    if has_cart?
      @stores[:wood] += 18 * multiplier
      @history << "+18 wood."
    else
      @stores[:wood] += 10 * multiplier
      @history << "+10 wood."
    end

    insert_next_story_entry

    @current_gather_wood_ticks = 0
  end

  def roll
    return @roll_override if @roll_override

    rand
  end

  def solo_run?
    no_huts? and has? :workshop
  end

  def iron_mine_cleared?
    @game.world.mine_cleared? :iron_mine
  end

  def no_huts?
    !has? :hut
  end

  def current_increase_population_ticks
    @current_increase_population_ticks
  end

  def thieves?
    return false if @thieves_gone

    !@thieves_stores[:wood].nil?
  end

  def increase_population_after
    @increase_population_after
  end

  def income
    @income
  end

  def workers
    @workers
  end

  def increase_population
    return if @population == max_population

    result = wandering_group

    if result == 1
      @history << "a stranger arrives in the night."
    elsif result < 5
      @history << "a weathered family takes up in one of the huts."
    elsif result < 10
      @history << "a small group arrives, all dust and bones."
    elsif result < 30
      @history << "a convoy lurches in, equal parts worry and hope."
    else
      @history << "the town's booming. word does get around."
    end

    @population += result

    @current_increase_population_ticks = 0
  end

  def allocate_worker worker
    return if @workers[:gatherer] == 0

    @workers[:gatherer] -= 1

    @workers[worker] += 1
  end

  def deallocate_worker worker
    return if @workers[worker] == 0

    @workers[:gatherer] += 1

    @workers[worker] -= 1
  end

  def builder_left?
    has? :her_locket
  end

  def has? key
    (@buildings[key] || 0) > 0 or (@stores[key] || 0) > 0
  end

  def has_population?
    @population > 1
  end

  def current_increase_population_ticks
    @current_increase_population_ticks
  end

  def kill_population amount
    amount = population if amount > @population
    @population -= amount

    if @population == 0
      @population = 1
      amount -= 1
      amount = 0 if amount < 0 #sanity check that probably doesn't need to be here
    end

    amount_left = amount

    @workers.keys.each do |key|
      amount_to_deduct = amount_left

      amount_to_deduct = @workers[key] if @workers[key] < amount_to_deduct

      @workers[key] -= amount_to_deduct

      amount_left -= amount_to_deduct
    end

    #no tests for this, ensures that population doesn't immediatly increase after deaths
    @current_increase_population_ticks = 0
  end

  def hut_count
    @buildings[:hut] || 0
  end

  def has_huts?
    hut_count > 0
  end

  def wood_count
    @stores[:wood] || 0
  end

  def next_story_entry
    story_line.find do |hash|
      hash[:if] and !@story_displayed.include?(hash[:message])
    end
  end

  def insert_next_story_entry
    story_to_add = next_story_entry

    return if !story_to_add

    @story_displayed << story_to_add[:message]

    @history << story_to_add[:message]
  end

  def story_line
    [
      {
        :if => wood_count > 5,
        :message => "hope she's okay. have to keep the fire going.",
      },
      {
        :if => @game.room.builder_ready?,
        :message => "she's woken up. says she can build things. says she's a friend.",
      },
      {
        :if => (@game.room.builder_ready? and wood_count > 40),
        :message => "the simple task brings solace. gives purpose. can't give up.",
      },
      {
        :if => (has_huts? and has_population?),
        :message => "can't help but reflect on humble beginnings. she smiles.",
      },

      {
        :if => has_population?,
        :message => "restless sleep. looking upon the village brings peace.",
      },
      {
        :if => (@game.room.available_crafts[:tradepost] and wood_count > 200),
        :message => "restless sleep. this simple task helps calm the nerves.",
      },
      {
        :if => (@game.room.available_crafts[:tradepost] and wood_count > 200),
        :message => "restless sleep. the voices speak of a compass.",
      },
      {
        :if => (@game.room.available_crafts[:tradepost] and wood_count > 300),
        :message => "restless sleep. the voices speak of a forest.",
      },

      {
        :if => ((has? :tradepost and fur_count > 200) or has? :compass),
        :message => "is there a world out there? beyond the village?",
      },
      {
        :if => ((has? :tradepost and fur_count > 200) or has? :compass),
        :message => "looking upon the border of the forest. figures dance in the shadows.",
      },
      {
        :if => ((has? :tradepost and fur_count > 350) or has? :compass),
        :message => "the thirst to explore is unbearable!",
      },
      {
        :if => ((has? :tradepost and fur_count > 350) or has? :compass),
        :message => "the worry in her eyes grows.",
      },

      {
        :if => (has? :compass),
        :message => "the compass spins. have to venture out. she says not to.",
      },
      {
        :if => (has? :compass),
        :message => "she warns of death.",
      },

      {
        :if => (!builder_left? and @game.world.total_deaths > 0),
        :message => "died out there. sure of it."
      },
      {
        :if => (!builder_left? and @game.world.total_deaths > 0),
        :message => "saw her face before collapsing. a glowing locket around her neck."
      },
      {
        :if => (!builder_left? and @game.world.total_deaths > 0),
        :message => "brought back to life by her?  how?"
      },
      {
        :if => (!builder_left? and @game.world.total_deaths > 1),
        :message => "she looks weary. almost as if every death affects her too.",
      },
      {
        :if => (!builder_left? and @game.world.total_deaths > 1),
        :message => "the locket around her neck glows brightly. a healing light.",
      },
      {
        :if => @game.outside.thieves?,
        :message => "the supplies have been turning up missing. thieves.",
      },

      {
        :if => (has_population? and has? :compass and wood_count > 300),
        :message => "the villagers. the fatigue in their eyes.",
      },
      {
        :if => (has_population? and has? :compass and wood_count > 300),
        :message => "back breaking labor. no rest for the villagers.",
      },
      {
        :if => (has_population? and has? :tannery and has? :compass),
        :message => "leather for finer things. must push them!",
      },
      {
        :if => (has_population? and has? :smokehouse and has? :compass),
        :message => "need to venture farther. the food from the smokehouse will help.",
      },
      {
        :if => (has_population? and has? :tannery and has? :compass and has? :smokehouse),
        :message => "make them work. through eternal night.",
      },
      {
        :if => (has_population? and has? :tannery and has? :compass and has? :smokehouse),
        :message => "they are slaves.",
      },
      {
        :if => (has? :workshop),
        :message => "torches to light the caves. spears to take lives.",
      },

      {
        :if => (has? :iron_mine),
        :message => "the roads bring safety.",
      },
      {
        :if => (has? :iron_mine),
        :message => "so many deaths for the mine.",
      },
      {
        :if => (has? :iron_mine),
        :message => "her sad eyes look upon the village.",
      },
      {
        :if => (has? :iron_mine),
        :message => "she weeps. but the thirst to conquer is unrelenting.",
      },

      {
        :if => (has? :coal_mine),
        :message => "she warns of greed. of reaching too far.",
      },
      {
        :if => (has? :coal_mine),
        :message => "tears in her eyes. she says to stop venturing out.",
      },

      {
        :if => (has? :sulphur_mine),
        :message => "they all stare sadly back. blackened faces from the soot.",
      },
      {
        :if => (has? :sulphur_mine),
        :message => "she whispers 'murderer'. within earshot.",
      },
      {
        :if => @game.room.available_crafts[:armoury],
        :message => "saw an armoury out there. will force her to build one.",
      },


      {
        :if => (has_population? and @game.world.ship_cleared?),
        :message => "she screams at the sight of the ship!",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "she says so much death has been brought to this world.",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "she says history has repeated itself. just like with him.",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "the jeweled locket around her neck begins to glow.",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "with a distraught look. a look of hatred.",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "she vanishes. into nothingness.",
      },
      {
        :if => (@game.world.ship_cleared? and has? :armoury),
        :message => "her jeweled locket left behind.",
      },

      {
        :if => (no_huts? and has? :compass and wood_count > 100),
        :message => "she gathers wood. her movements. weighed down, despondent.",
      },
      {
        :if => (no_huts? and has? :compass and wood_count > 100),
        :message => "yet her starlit eyes show a soul, unconquerable.",
      },

      {
        :if => solo_run?,
        :message => "with a look of utter defeat, she falls. overwhelmed by exhausion!"
      },

      {
        :if => solo_run?,
        :message => "she screams! convulsions rip through her body!"
      },

      {
        :if => solo_run?,
        :message => "she stops moving. her locket unlatches."
      },

      {
        :if => (no_huts? and iron_mine_cleared?),
        :message => "she's awake. shivers in the corner."
      },

      {
        :if => (no_huts? and iron_mine_cleared?),
        :message => "says she wants to leave this eternal darkness."
      },

      {
        :if => (no_huts? and iron_mine_cleared?),
        :message => "says to find a ship."
      },

      {
        :if => (no_huts? and @game.world.ship_cleared?),
        :message => "she looks upon the ship. as if it were an old friend.",
      },

      {
        :if => (no_huts? and @game.world.ship_cleared?),
        :message => "with a solemn smile on her face.",
      },

      {
        :if => (no_huts? and @game.world.ship_cleared?),
        :message => "she asks to be taken away.",
      }
    ]
  end

  def gather_wood_tick
    return if can_gather_wood?

    @current_gather_wood_ticks += 1
  end

  def check_traps_tick
    return if can_check_traps?

    @current_check_traps_ticks += 1
  end

  def worker_count
    @workers.keys.map { |k| @workers[k] }.inject(:+)
  end

  def tick_income
    return if !@workers[:gatherer]

    if worker_count != @population
      @workers[:gatherer] += @population - worker_count
    end

    @workers.keys.each do |worker|
      @income[worker].apply @workers[worker], @stores
    end

    if thieves?
      @income[:thieves].apply 1, @stores, @thieves_stores
    end
  end

  def tick_population
    #no tests for this, ensures that population doesn't immediatly increase after the first hut is built
    return if hut_count == 0

    @current_increase_population_ticks += 1

    return if @current_increase_population_ticks < @increase_population_after

    increase_population

    schedule_next_population_increase
  end

  def tick
    # puts "tick"
    # puts @current_increase_population_ticks
    # puts @increase_population_after
    gather_wood_tick
    check_traps_tick
    tick_population
    tick_income
    tick_thieves
  end
end
