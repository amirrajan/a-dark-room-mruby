class ThievesTests < Tests
  def define_tests
    it "comes when compass is available and at least one store is above 5000 and has atleast 10 huts" do
      game = game_ready_to_play

      game.tick
      assert game.outside.thieves?, false

      game.stores[:compass] = 1

      game.tick
      assert game.outside.thieves?, false

      game.buildings[:hut] = 10
      game.stores[:wood] = 5000

      game.tick
      assert game.outside.thieves?, true
    end

    it "thieves do not come back once killed" do
      game = game_ready_to_play
      game.outside.start_thieves

      game.outside.kill_thieves
      game.tick

      assert game.outside.thieves?, false
    end

    it "thieves steal supplies" do
      game = game_ready_to_play

      unlock_thieves game

      game.tick

      builder_income = game.builder_gather_rate

      assert game.stores[:wood], 4999 + builder_income
      assert game.stores[:fur], 4999
      assert game.stores[:meat], 4999
    end

    it "thieves steal even if others are 0" do
      game = game_ready_to_play

      unlock_thieves game

      game.tick

      game.stores[:wood] = 5000
      game.stores[:fur] = 0
      game.stores[:meat] = 0

      game.tick

      assert game.stores[:wood], 4999
      assert game.stores[:fur], 0
      assert game.stores[:meat], 0
    end

    it "thief event is available" do
      game = game_ready_to_play
      unlock_thieves game
      game.tick
      assert game.outside.thieves?, true
      game.active_module = :room
      game.outside.population = 2
      game.outside.thieves_stores[:wood] = 1001
      assert TheThief.new(game).is_available?, true
    end

    it "supplies stolen by thieves is returned on death" do
      game = game_ready_to_play

      unlock_thieves game

      game.tick

      assert game.outside.thieves_stores[:wood], 1
      assert game.outside.thieves_stores[:fur], 1
      assert game.outside.thieves_stores[:meat], 1

      game.outside.kill_thieves

      builder_income = game.builder_gather_rate

      assert game.stores[:wood], 5000 + builder_income
      assert game.stores[:fur], 5000
      assert game.stores[:meat], 5000
    end

    it "forgiving thieves gives stealthy perk" do
      game = game_ready_to_play

      unlock_thieves game

      game.tick

      game.outside.forgive_thieves

      assert game.outside.thieves?, false

      assert game.has_perk?(:stealthy), true
    end

    it "thieves can only be killed once" do
      game = game_ready_to_play

      unlock_thieves game

      game.tick

      game.outside.kill_thieves
      game.outside.kill_thieves

      builder_income = game.builder_gather_rate

      game.buildings[:hut] = 10
      assert game.stores[:wood], 5000 + builder_income
      assert game.stores[:fur], 5000
      assert game.stores[:meat], 5000
    end

    def unlock_thieves game
      game.buildings[:hut] = 10
      game.stores[:wood] = 5000
      game.stores[:fur] = 5000
      game.stores[:meat] = 5000
      game.stores[:compass] = 1
      game.tick
      assert game.outside.thieves?, true
    end
  end

  def game_ready_to_play
    game = Game.new
    # game.load
    # game.game_state.clear
    game.room.light_fire
    game.room.unlock_forest
    game.room.builder_ready

    game.stores[:wood] = game.room.crafts[:hut].cost[:wood]
    game.room.unlock_crafts
    game.room.craft(:hut)

    game.stores[:wood] = 0
    game.stores[:fur] = 0
    game.stores[:meat] = 0

    game.outside.population = 4
    game
  end
end
