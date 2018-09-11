# fswatch ./app/tests.rb | xargs -n1 -I{} sh ./build_and_run.sh

class Tests
  def initialize
    @befores = []
    @specifies = {}
  end

  def run
    puts "# #{self.class.to_s}"
    define_tests

    puts ""

    @specifies.each do |k, v_tuple|
      puts "- #{k}"
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

    puts ""

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

  def assert_not actual, expected, message = nil
    if actual == expected
      raise "`assert_not` failure: #{message}\n[#{actual}] of type [#{actual.class}] equaled [#{expected}] of type [#{expected.class}]."
    end
  end

  def assert actual, expected, message = nil
    if actual != expected
      raise "`assert` failure:#{message}\n[#{actual}] of type [#{actual.class}] did not equal [#{expected}] of type [#{expected.class}]."
    end
  end

  def assert_nil o, message = nil
    if !o.nil?
      raise "`assert_nil` failure: #{message}\nExpected [#{o}] to be nil, but was of type [#{o.class}]."
    end
  end

  def assert_not_nil o, message = nil
    if o.nil?
      raise "`assert_not_nil` failure: #{message}\nExpected object that was passed in to not be nil."
    end
  end

  def assert_contains list, expected, message = nil
    found = false

    list.each do |i|
      found = true if i == expected
    end

    if !found
      raise "`assert_contains` failure: #{message}\n[#{expected}] was not contained in:\n\n#{list.join("\n")}"
    end
  end
end
