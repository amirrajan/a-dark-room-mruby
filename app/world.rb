class World < Hash
  def initialize game
    @game = game
    @asthetics = Hash.new
    @landmarks = Hash.new
    @cleared = Hash.new
    reset
  end

  def total_deaths
    @food_deaths + @water_deaths + @battle_deaths
  end

  def reset
    @food_deaths = 0
    @water_deaths = 0
    @battle_deaths = 0
  end

  def ship_cleared?
    false
  end

  def mine_cleared? mine
    false
  end
end
