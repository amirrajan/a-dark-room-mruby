class Room
  attr_accessor :fire, :temperature, :builder_status,
                :available_crafts, :available_trades, :available_tools,
                :current_stoke_ticks, :forest_unlocked

  def initialize history, stores, buildings, workers, game
    @history = history
    @stores = stores
    @fire = :dead
    @temperature = :cold
    @buildings = buildings
    @workers = workers
    @game = game

    @fire_states = {
      :dead => { :next => :smoldering, :prev => :dead, :value => 0 },
      :smoldering => { :next => :flickering, :prev => :dead, :value => 1 },
      :flickering => { :next => :burning, :prev => :smoldering, :value => 2 },
      :burning => { :next => :roaring, :prev => :flickering, :value => 3 },
      :roaring => { :next => :roaring, :prev => :burning, :value => 4 }
    }

    @room_temps = {
      :freezing => { :next => :cold, :prev => :freezing, :value => 0 },
      :cold => { :next => :mild, :prev => :freezing, :value => 1 },
      :mild => { :next => :warm, :prev => :cold, :value => 2 },
      :warm => { :next => :hot, :prev => :mild, :value => 3 },
      :hot => { :next => :hot, :prev => :warm, :value => 4 },
    }

    @stoke_ready_after = 10
    @current_stoke_ticks = 0

    @cool_fire_after = 3 * 60
    @current_cool_fire_ticks = 0

    @room_temp_changes_after = 25
    @current_room_temp_ticks = 0

    @builder_status_change_after = 20
    @current_builder_status_ticks = 0
    @builder_status = -1

    @forest_unlocked = false

    #if anything is added to this list, make sure to add an entry to game.rb/def order
    # @crafts = {
    #   :cart => Cart.new(@buildings),
    #   :trap => Trap.new(@buildings),
    #   :hut => Hut.new(@buildings),
    #   :lodge => Lodge.new(@buildings),
    #   :tradepost => Tradepost.new(@buildings),
    #   :tannery => Tannery.new(@buildings),
    #   :smokehouse => Smokehouse.new(@buildings),
    #   :workshop => Workshop.new(@buildings),
    #   :steelworks => Steelworks.new(@buildings),
    #   :iron_mine => IronMine.new(@buildings),
    #   :coal_mine => CoalMine.new(@buildings),
    #   :sulphur_mine => SulphurMine.new(@buildings),
    #   :armoury => Armoury.new(@buildings),
    # }

    #if anything is added to this list, make sure to add an entry to game.rb/def order
    # @trades = {
    #   :bait => Bait.new,
    #   :scales => Scales.new,
    #   :teeth => Teeth.new,
    #   :compass => Compass.new,
    #   :leather => Leather.new,
    #   :cured_meat => CuredMeat.new,
    #   :bolas =>  Bolas.new,
    #   :iron => Iron.new,
    #   :coal => Coal.new,
    #   :steel => Steel.new,
    #   :bullets => Bullets.new,
    #   :grenade => Grenade.new,
    #   :battery => Battery.new,
    #   :katana => Katana.new,
    #   :alien_alloy => AlienAlloy.new
    # }

    #if anything is added to this list, make sure to add an entry to game.rb/def order
    # @tools = {
    #   :bone_spear => BoneSpear.new,
    #   :torch => Torch.new,
    #   :waterskin => Waterskin.new,
    #   :rucksack => Rucksack.new,
    #   :leather_armour => LeatherArmour.new,
    #   :iron_sword => IronSword.new,
    #   :cask => Cask.new,
    #   :wagon => Wagon.new,
    #   :iron_armour => IronArmour.new,
    #   :steel_sword =>  SteelSword.new,
    #   :water_tank => WaterTank.new,
    #   :convoy => Convoy.new,
    #   :steel_armour => SteelArmour.new,
    #   :rifle => Rifle.new,
    #   :war_mantle => WarMantle.new
    # }

    @available_crafts = Hash.new
    @available_trades = Hash.new
    @available_tools = Hash.new
  end

  def begining_of_game
    return !@stores[:wood]
  end

  def has_funds_for action
    return true if begining_of_game

    cost_for[action][:wood] <= @stores[:wood]
  end

  def light_fire
    return false if !has_funds_for :light_fire

    @history << "the light from the fire spills from the windows, out into the dark."

    @fire = :burning

    pay_for :light_fire

    @current_stoke_ticks = 0

    return true
  end

  def pay_for action
    return if begining_of_game

    @stores[:wood] -= cost_for[action][:wood]
  end

  def unlock_forest
    return if @forest_unlocked

    @forest_unlocked = true

    if(@game.completed_once?)
      @stores[:wood] = 1500
      @stores[:fur] = 500
      @history << "a windfall of supplies. just outside the door."
    else
      @stores[:wood] = 4
      @history << "the wood is running low."
    end

    return false
  end

  def stoke_ready_after
    @stoke_ready_after
  end

  def tick_stoke
    return if fire_is_out?

    return if can_stoke?

    @current_stoke_ticks += 1
  end

  def tick
    # cool_fire

    # change_room_temp

    # update_builder_status

    # record_fire_state

    # record_room_temp

    tick_stoke

    # unlock_crafts

    # unlock_trades

    # unlock_tools
  end

  def stoke
    return false if !can_stoke?

    return false if !has_funds_for :stoke

    @fire = @fire_states[@fire][:next]

    pay_for :stoke

    reset_fire_cool_downs

    return true
  end

  def can_stoke?
    @current_stoke_ticks == @stoke_ready_after
  end

  def title
    return "a dark room" if @fire_states.keys.take(2).include? @fire

    "a firelit room"
  end

  def fire_is_out?
    @fire == :dead
  end

  def cost_for
    {
      :stoke => { :wood => 1 },
      :light_fire => { :wood => 5 }
    }
  end

  def reset_fire_cool_downs
    @current_stoke_ticks = 0
    @current_cool_fire_ticks = 0
    record_fire_state true
  end

  def record_fire_state force = false
    if @previous_fire_state != @fire || force

      @history << "the fire is #{ @fire.to_s }."

      @previous_fire_state = @fire
    end
  end
end
