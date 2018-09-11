class IncomeTests < Tests
  def define_tests
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
      @game.room.builder_ready

      @game.stores[:wood] = @game.room.crafts[:hut].cost[:wood]
      @game.room.unlock_crafts
      @game.room.craft(:hut)

      @game.stores[:wood] = @game.room.crafts[:lodge].cost[:wood]
      @game.stores[:fur] = @game.room.crafts[:lodge].cost[:fur]
      @game.stores[:meat] = @game.room.crafts[:lodge].cost[:meat]
      @game.room.unlock_crafts
      @game.room.craft(:lodge)

      @game.outside.population = 4
    end

    it "villagers contribute to gathering wood" do
      @game.stores[:wood] = 0

      @game.outside.income[:gatherer].after.times do
        @game.tick
      end

      assert @game.workers[:gatherer], @game.outside.population

      builder_income = @game.builder_gather_rate

      expected_income = @game.workers[:gatherer] * @game.outside.income[:gatherer].stores[:wood] + builder_income

      assert @game.stores[:wood], expected_income
    end

    it "trappers need meat to create bait" do
      @game.stores[:meat] = 0

      @game.tick

      @game.outside.population.times { @game.outside.allocate_worker(:trapper) }

      @game.outside.income[:trapper].after.times do
        @game.tick
      end

      assert @game.stores[:meat], 0
      assert @game.stores[:bait], nil
    end

    it "trappers take meat to create bait" do
      @game.stores[:meat] = 4

      @game.tick

      @game.outside.population.times do
        @game.outside.allocate_worker(:trapper)
      end

      @game.outside.income[:trapper].after.times do
        @game.tick
      end

      assert @game.stores[:meat], 0
      assert @game.stores[:bait], 4
    end

    it "allocated villagers to a lodge gather meat and fur" do
      @game.stores[:meat] = 0
      @game.stores[:fur] = 0

      @game.tick

      @game.outside.population.times { @game.outside.allocate_worker(:hunter) }

      @game.outside.income[:hunter].after.times do
        @game.tick
      end

      expected_income_meat = @game.outside.population * @game.outside.income[:hunter].stores[:meat]
      expected_income_fur = @game.outside.population * @game.outside.income[:hunter].stores[:fur]

      assert @game.stores[:meat], expected_income_meat
      assert @game.stores[:fur], expected_income_fur
    end

    it "workers cannot be over allocated" do
      @game.tick

      (@game.outside.population + 1).times { @game.outside.allocate_worker(:hunter) }

      assert @game.workers[:gatherer], 0
      assert @game.workers[:hunter], 4
    end

    it "a change in population increases gatherers" do
      @game.outside.population = 4

      @game.tick

      @game.outside.population.times { @game.outside.allocate_worker(:hunter) }

      @game.outside.population = 8

      @game.tick

      assert @game.workers[:gatherer], 4
      assert @game.workers[:hunter], 4
    end

    it "deallocate work puts a worker back into gatherers" do
      @game.tick

      @game.outside.allocate_worker(:hunter)

      assert @game.workers[:gatherer], 3
      assert @game.workers[:hunter], 1

      @game.outside.deallocate_worker(:hunter)

      assert @game.workers[:gatherer], 4
      assert @game.workers[:hunter], 0

      @game.outside.deallocate_worker(:hunter)

      assert @game.workers[:gatherer], 4
      assert @game.workers[:hunter], 0
    end
  end
end
