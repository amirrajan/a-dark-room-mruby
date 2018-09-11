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
    @crafts = {
      :cart => Cart.new(@buildings),
      :trap => Trap.new(@buildings),
      :hut => Hut.new(@buildings),
      :lodge => Lodge.new(@buildings),
      :tradepost => Tradepost.new(@buildings),
      :tannery => Tannery.new(@buildings),
      :smokehouse => Smokehouse.new(@buildings),
      :workshop => Workshop.new(@buildings),
      :steelworks => Steelworks.new(@buildings),
      :iron_mine => IronMine.new(@buildings),
      :coal_mine => CoalMine.new(@buildings),
      :sulphur_mine => SulphurMine.new(@buildings),
      :armoury => Armoury.new(@buildings),
    }

    # if anything is added to this list, make sure to add an entry to game.rb/def order
    @trades = {
      :bait => Bait.new,
      :scales => Scales.new,
      :teeth => Teeth.new,
      :compass => Compass.new,
      :leather => Leather.new,
      :cured_meat => CuredMeat.new,
      :bolas =>  Bolas.new,
      :iron => Iron.new,
      :coal => Coal.new,
      :steel => Steel.new,
      :bullets => Bullets.new,
      :grenade => Grenade.new,
      :battery => Battery.new,
      :katana => Katana.new,
      :alien_alloy => AlienAlloy.new
    }

    # if anything is added to this list, make sure to add an entry to game.rb/def order
    @tools = {
      :bone_spear => BoneSpear.new,
      :torch => Torch.new,
      :waterskin => Waterskin.new,
      :rucksack => Rucksack.new,
      :leather_armour => LeatherArmour.new,
      :iron_sword => IronSword.new,
      :cask => Cask.new,
      :wagon => Wagon.new,
      :iron_armour => IronArmour.new,
      :steel_sword =>  SteelSword.new,
      :water_tank => WaterTank.new,
      :convoy => Convoy.new,
      :steel_armour => SteelArmour.new,
      :rifle => Rifle.new,
      :war_mantle => WarMantle.new
    }

    @available_crafts = Hash.new
    @available_trades = Hash.new
    @available_tools = Hash.new
  end

  def tools
    @tools
  end

  def builder_ready
    @builder_status = 4
  end

  def crafts
    @crafts
  end

  def at_building_maximum? craft_key
    at_purchasable_maximum? craft_key, @buildings, @crafts
  end

  def at_purchasable_maximum? key, quantity_lookup, maximum_lookup
    quantity = quantity_lookup[key] || 0

    return quantity >= maximum_lookup[key].maximum
  end

  def craft key, amount = 1
    return false if !afford_craft? key

    return false if at_building_maximum? key

    @crafts[key].cost.keys.map do |material|
      @stores[material] -= @crafts[key].cost[material]
    end

    @buildings[key] ||= 0

    @buildings[key] += 1

    if key ==:hut && @game.slaves?
      @history << "saddened, builder puts up another hut." #not tested
    else
      @history << @crafts[key].build_message
    end

    true
  end

  def builder_ready?
    @builder_status >= 4
  end

  def begining_of_game
    return !@stores[:wood]
  end

  def has_funds_for action
    return true if begining_of_game

    cost_for[action][:wood] <= @stores[:wood]
  end

  def cool_fire_after
    @cool_fire_after
  end

  def change_room_temp
    @current_room_temp_ticks += 1

    return if @current_room_temp_ticks != @room_temp_changes_after

    limit_reached = @room_temps[@temperature][:value] >= @fire_states[@fire][:value]
    limit_exceeded = @room_temps[@temperature][:value] > @fire_states[@fire][:value]
    @temperature = @room_temps[@temperature][:next] unless limit_reached
    @temperature = @room_temps[@temperature][:prev] if limit_exceeded
    @current_room_temp_ticks = 0
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

  def update_builder_status
    return if @builder_status > 3

    @current_builder_status_ticks += 1

    if @current_builder_status_ticks == 15 and @builder_status == 1
      unlock_forest
    end

    if @builder_status == -1 and !fire_is_out?
      @builder_status += 1
    end

    return if @current_builder_status_ticks != @builder_status_change_after

    if @builder_status == 0 and !fire_is_out?
      @history << "a ragged stranger stumbles through the door and collapses in the corner."
      @builder_status += 1
    elsif @builder_status == 1 and [:warm, :hot].include? @temperature
      @history << "the stranger shivers, and mumbles quietly. her words are unintelligible."
      @builder_status += 1
    elsif @builder_status == 2 and [:warm, :hot].include? @temperature
      @history << "the stranger in the corner stops shivering. her breathing calms."
      @builder_status += 1
    elsif @builder_status == 3
      @builder_status += 1
    end

    @current_builder_status_ticks = 0
  end

  def unlock_crafts
    return if begining_of_game

    return if !builder_ready?

    @crafts.keys.map { |key| unlock_craft key }
  end

  def see_purchaseable? purchasable
    current_wood = @stores[:wood]

    all_encountered = all_materials_encountered(purchasable.cost)

    current_wood > purchasable.half_wood_cost and all_encountered
  end

  def all_materials_encountered cost
    (cost.keys - @stores.keys).count == 0
  end

  def afford_craft? craft_key
    @stores.afford? @crafts[craft_key].cost
  end

  def unlock_craft craft_key
    return if @available_crafts[craft_key]

    return if !see_purchaseable? @crafts[craft_key]

    to_unlock = @crafts[craft_key]

    return if !@buildings[:hut] and to_unlock.requires_hut?

    if to_unlock.unlocks_workers?
      to_unlock.workers.each { |worker| @workers[worker] ||= 0 }
    end

    @available_crafts[craft_key] = to_unlock

    if to_unlock.buyable? and !@game.solo_run? #solo run scenario untested
      @history << to_unlock.builder_message
    end
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

  def builder_status_change_after
    @builder_status_change_after
  end

  def forest_unlocked?
    @forest_unlocked
  end

  def tick_stoke
    return if fire_is_out?

    return if can_stoke?

    @current_stoke_ticks += 1
  end

  def cool_fire
    @current_cool_fire_ticks += 1

    return if @current_cool_fire_ticks != @cool_fire_after

    @fire = @fire_states[@fire][:prev]
    @current_cool_fire_ticks = 0
  end

  def unlock_tools
    return if !@buildings[:workshop]

    @tools.keys.map { |key| unlock_tool key }
  end

  def unlock_tool tool_key
    return if @available_tools[tool_key]

    return if !see_purchaseable? @tools[tool_key]

    return if !@tools[tool_key].meets_prerequisite? @available_tools

    to_unlock = @tools[tool_key]

    @available_tools[tool_key] = to_unlock
  end

  def unlock_trades
    @trades.keys.each do |key|
      trade = @trades[key]
      store_key = trade.available_if

      @available_trades[key] ||= 0 if @stores[store_key]
    end
  end

  def tick
    cool_fire

    change_room_temp

    update_builder_status

    record_fire_state

    record_room_temp

    tick_stoke

    unlock_crafts

    unlock_trades

    unlock_tools
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

  def room_temp_changes_after
    @room_temp_changes_after
  end

  def fire_is_out?
    @fire == :dead
  end

  def record_room_temp
    if @previous_temperature != @temperature
      @history << "the room is #{ @temperature.to_s }."
      @previous_temperature = @temperature
    end
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
