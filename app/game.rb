class Game
  def initialize
    @room = Room.new
  end

  def hello_world
    puts @room.name
  end
end
