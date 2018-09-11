class Events
  attr_accessor :after, :all, :active_event, :current_ticks

  def initialize game
    @game = game
    @all = [
      NoisesOutside.new(game),
      TheNomad.new(game),
      NoisesInside.new(game),
      TheBeggar.new(game),
      WoodGamble.new(game),
      FurGamble.new(game),
      RuinedTraps.new(game),
      BeastAttack.new(game),
      NoisesInBrush.new(game),
      TheScout.new(game),
      ShiningLocket.new(game),
      LocketReveals.new(game),
      TheThief.new(game),
      TheMaster.new(game),
      SoldierAttack.new(game)
    ]
    @current_ticks = 0
  end

  def roll
    rand
  end

  def schedule
    @after = ((roll * (6.0 - 3.0)) + 3.0).floor * 60
    @current_ticks = 0
  end

  def available
    @all.select { |e| e.is_available? }
  end

  def trigger_event
    temp = available.sample

    return if !temp

    temp.history = @game.history

    temp.init_scenes
    temp.current_scene = :start
    @active_event = temp
    schedule
  end

  def complete
    @active_event = nil

    schedule
  end

  def tick
    @current_ticks += 1

    @active_event = nil

    return if @current_ticks < after

    return if active_event

    trigger_event
  end
end
