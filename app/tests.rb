# fswatch ./app/tests.rb | xargs -n1 -I{} sh ./build_and_run.sh

class Tests
  def initialize
    @befores = []
    @specifies = {}
  end

  def run
    define_tests

    @specifies.each do |k, v_tuple|
      before_index, specify_it = v_tuple
      begin
        if before_index != -1
          @befores[before_index].call
        end
      rescue => e
        puts "Exception in `before` associated with: #{k}."
        raise e
      end

      begin
        specify_it.call
      rescue => e
        puts "Exception in `specify/it`: #{k}."
        raise e
      end
    end

    return true
  end

  def before(&block)
    @befores << block
  end

  def it(message, &block)
    specify(message, &block)
  end

  def specify(message, &block)
    @specifies[message] = [@befores.length - 1, block]
  end

  def define_tests
    raise "`define_tests` not defined for #{self.class}."
  end

  def new_game
    puts "newing up game"
    @game = Game.new
  end

  def room_spec_tests
    new_game
    assert @game.room.title, "a dark room"
  end

  def assert actual, expected, message = nil
    if actual != expected
      raise "#{message}\n[#{actual}] of type [#{actual.class}] did not equal [#{expected}] of type [#{expected.class}]."
    end
  end
end
