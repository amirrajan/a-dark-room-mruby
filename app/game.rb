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
    # @events = Events.new self
    # @events.schedule
    # @outside = Outside.new @history, @stores, @buildings, @workers, self
    # @world = World.new self
    # @game_state = GameState.new self
    # @cost_string = CostString.new
    @last_history_count = 0
  end

  def tick_speed
    0.7 #in seconds
  end

  def completed_once?
    (@fastest_completion_ticks || 0) > 5
  end

  def tick
    @room.tick
    # @outside.tick
    # @events.tick if(white_listed_modules.include? @active_module)
    # @world.tick
    # builder_gathers_wood

    # if @world.ship_cleared?
    #   if @current_lift_off_ticks < @lift_off_after
    #     @current_lift_off_ticks += 1
    #   end
    # end

    # @history << "awake. head throbbing. the voices say to survive." if @tick_count == 1

    @tick_count += 1

    # @tick_history.clear
    # difference = @history.count - @last_history_count
    # @tick_history.push(*@history[-(difference)..@history.count]) if difference > 0
    # @last_history_count = @history.count
  end
end
