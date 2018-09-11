class Tests; end

class RoomTests < Tests
  def hello_room
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
    end

    specify "title is based off of fire" do
      assert @game.room.title, "a dark room"
    end
  end

  def stoking_and_lighting_fire_after_forest_is_unlocked
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
    end

    it "requires 1 wood to stoke fire" do
      @game.room.stoke_ready_after.times { @game.tick }
      assert @game.room.begining_of_game, false, "At beginning of game?"
      assert @game.room.stoke, true, "Did stoke succeed?"
      assert @game.stores[:wood], 3, "Was wood decremented?"
    end

    it "isn't preformed if there aren't enough funds" do
      @game.room.stoke_ready_after.times { @game.tick }
      @game.stores[:wood] = 0
      assert @game.room.stoke, false, "Stoke failed if no wood?"
    end

    it "requires 5 wood to light fire" do
      @game.room.fire = :dead
      assert @game.room.light_fire, false, "Can fire be lit once forest is unlocked and no wood?"
      @game.stores[:wood] = 10
      assert @game.room.light_fire, true,  "Can fire be lit once forest is unlocked and has enough wood?"
      assert @game.stores[:wood], 5, "Word is decremented correctly?"
    end
  end

  def starting_and_stoking_fire
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
    end

    it "a fire can be lit" do
      @game.room.light_fire
      assert @game.room.fire, :burning
    end

    it "allows stoking after a timer interval has passed" do
      @game.room.light_fire

      assert @game.room.can_stoke?, false

      @game.room.stoke_ready_after.times do |i|
        assert @game.room.current_stoke_ticks, i, "Stoke ticks incremented correctly?"
        @game.tick
      end

      assert @game.room.can_stoke?, true, "Can stoke?"
    end

    it "stoke is ignored if it cannot stoke" do
      @game.room.light_fire

      assert @game.room.can_stoke?, false

      @game.room.stoke

      assert @game.room.fire, :burning
    end

    it "current stoke ticks doesn't surpass ready ticks" do
      @game.room.light_fire

      (@game.room.stoke_ready_after + 1).times do |i|
        @game.tick
      end

      assert @game.room.current_stoke_ticks, @game.room.stoke_ready_after
    end

    it "stoke ticks remains zero if fire is dead" do
      @game = Game.new
      @game.tick
      assert @game.room.fire, :dead
      assert @game.room.fire_is_out?, true
      assert @game.room.current_stoke_ticks, 0
    end

    it "stoking interval and fire status increase reset after stoking" do
      @game.room.light_fire
      @game.room.stoke_ready_after.times { @game.tick }
      @game.room.stoke
      assert @game.room.fire, :roaring
      assert @game.room.can_stoke?, false
    end

    it "initialize the game with fire state" do
      @game = Game.new
      @game.room.tick
      assert fire_history.last, "the fire is dead."
    end

    it "notifies the state of the fire" do
      @game.room.light_fire

      @game.room.tick

      assert fire_history.last, "the fire is burning."
    end

    it "records fire state everytime the fire is stoked" do
      @game = Game.new
      @game.tick
      assert fire_history[0], "the fire is dead."

      @game.room.light_fire
      @game.tick
      assert fire_history[1], "the fire is burning."

      @game.room.stoke_ready_after.times { @game.tick }
      @game.room.stoke
      @game.tick
      assert fire_history[2], "the fire is roaring."

      @game.room.stoke_ready_after.times { @game.tick }
      @game.room.stoke
      @game.tick
      assert fire_history[3], "the fire is roaring."
    end
  end

  def cooling_fire
    it "cools if it hasn't been stoked" do
      @game.room.light_fire
      @game.room.stoke_ready_after.times { @game.tick }
      @game.room.stoke
      assert @game.room.fire, :roaring
      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :burning
      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :flickering
      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :smoldering
      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :dead
      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :dead
    end

    it "resets cooling if fire is stoked" do
      @game.room.light_fire
      @game.room.stoke_ready_after.times { @game.tick }
      @game.room.stoke
      assert @game.room.fire, :roaring
      (@game.room.cool_fire_after - 1).times { @game.tick }
      @game.room.stoke
      (@game.room.cool_fire_after - 1).times { @game.tick }
      assert @game.room.fire, :roaring
    end
  end

  def scripted_unlock_of_forest
    it "scripted unlock of forest" do
      @game = Game.new
      @game.room.light_fire
      @game.room.builder_status_change_after.times { @game.tick }
      assert @game.room.forest_unlocked?, false, "Forest still locked?"
      @game.room.builder_status_change_after.times { @game.tick }
      assert @game.room.forest_unlocked?, true, "Forest unlocked?"
      assert @game.stores[:wood], 4, "Wood used?"
    end
  end

  def room_heating
    before do
      @game = Game.new
    end

    it "room heats up relative to fire's current state, but doesn't move past" do
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :freezing, "freezing room?"
      @game.room.light_fire
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :cold, "cold room?"
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :mild, "cold room?"
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :warm, "warm room?"
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :warm, "still warm room?"

      @game.room.stoke
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :hot, "hot room?"
    end

    it "records temp changes" do
      @game.tick
      @game.room.light_fire
      @game.room.room_temp_changes_after.times { @game.tick }

      assert temperature_history[0], "the room is cold."
      assert temperature_history[1], "the room is mild."
    end

    it "records cooling temperatures" do
      @game.tick
      @game.room.light_fire
      @game.room.room_temp_changes_after.times { @game.tick }
      @game.room.room_temp_changes_after.times { @game.tick }
      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :warm
      @game.room.stoke

      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :hot

      @game.room.cool_fire_after.times { @game.tick }
      assert @game.room.fire, :burning

      @game.room.room_temp_changes_after.times { @game.tick }
      assert @game.room.temperature, :warm

      assert temperature_history.last, "the room is warm."
    end
  end

  def builder_sequence
    before do
      @game = Game.new
    end

    it "builder squence" do
      @game.room.light_fire

      @game.room.builder_status_change_after.times { @game.tick }

      assert_contains @game.history,
                      "the light from the fire spills from the windows, out into the dark."

      @game.room.builder_status_change_after.times { @game.tick }

      assert_contains @game.history,
                      "a ragged stranger stumbles through the door and collapses in the corner."

      @game.room.room_temp_changes_after.times { @game.tick }
      @game.room.builder_status_change_after.times { @game.tick }

      assert_contains @game.history,
                      "the stranger shivers, and mumbles quietly. her words are unintelligible."

      @game.room.builder_status_change_after.times { @game.tick }

      assert_contains @game.history,
                      "the stranger in the corner stops shivering. her breathing calms."
    end
  end

  def define_tests
    hello_room
    stoking_and_lighting_fire_after_forest_is_unlocked
    starting_and_stoking_fire
    cooling_fire
    scripted_unlock_of_forest
    room_heating
    builder_sequence
  end

  def fire_history
    @game.history.select { |h| h.start_with?("the fire") }
  end

  def temperature_history
    @game.history.select { |h| h.start_with?("the room") }
  end
end
