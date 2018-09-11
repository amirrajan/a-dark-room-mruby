class PopulationTests < Tests
  def define_tests
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
      @game.stores[:wood] = @game.room.crafts[:hut].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      @game.room.craft(:hut)

      @game.stores[:wood] = @game.room.crafts[:lodge].cost[:wood]
      @game.stores[:fur] = @game.room.crafts[:lodge].cost[:fur]
      @game.stores[:meat] = @game.room.crafts[:lodge].cost[:meat]
      @game.room.unlock_crafts
      @game.room.craft(:lodge)
      @game.outside.roll_override = 0.5

      @population = 0
    end

    it "increase population up to the max" do
      @game.outside.population = 3
      @game.outside.increase_population
      assert @game.outside.current_increase_population_ticks, 0
      assert @game.outside.wandering_group, 1
      assert @game.outside.population, 4
    end

    it "kills population (except for one dude)" do
      @game.outside.max_population.times { @game.outside.increase_population }
      @game.tick
      @game.outside.allocate_worker(:trapper)
      assert @game.workers[:gatherer], 3
      assert @game.workers[:trapper], 1
      @game.outside.kill_population(4)
      assert @game.outside.population, 1
      assert @game.workers[:gatherer], 0
      assert @game.workers[:trapper], 1
    end

    it "population cannot exceed hut capacity" do
      5.times { @game.outside.increase_population }

      assert @game.outside.population, 4
    end

    it "increase population after time has passed" do
      assert @game.outside.population, 0

      @game.outside.increase_population_after.times do
        @game.tick
      end

      assert_not @game.outside.population, 0
    end

    it "increases population by a random amount" do
      @game.outside.increase_population

      assert @game.outside.population, 3
    end
  end
end
