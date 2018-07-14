# fswatch ./app/tests.rb | xargs -n1 -I{} sh ./build_and_run.sh

class Tests
  def run
    puts "here"
    room_spec_tests
  end

  def new_game
    puts "newing up game"
    @game = Game.new
  end

  def room_spec_tests
    new_game
    assert @game.room.title, "a dark room"
  end

  def assert actual, expected
    if actual != expected
      raise "#{actual} did not equal #{expected}"
    end
  end
end
