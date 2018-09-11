class CraftingTests < Tests
  def unlocking_crafts_some_of_which_require_huts
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
      @game.buildings[:hut] = 1
    end

    it "is locked until half wood is available for craft and other materials have been discovered" do
      @game.stores[:wood] = @game.room.crafts[:lodge].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      assert_nil @game.room.available_crafts[:lodge]
      @game.stores[:fur] = 0
      @game.stores[:meat] = 0
      @game.room.unlock_crafts
      assert_not_nil @game.room.available_crafts[:lodge]
    end

    it "decrements cost of all materials used" do
      @game.stores[:wood] = @game.room.crafts[:lodge].cost[:wood]
      @game.stores[:fur] = @game.room.crafts[:lodge].cost[:fur]
      @game.stores[:meat] = @game.room.crafts[:lodge].cost[:meat]
      @game.room.builder_ready
      @game.room.unlock_crafts
      assert_not @game.room.available_crafts[:lodge], nil, "Lodge available to craft?"
      @game.room.craft(:lodge)
      assert @game.stores[:wood], 0
      assert @game.stores[:fur], 0
      assert @game.stores[:meat], 0
    end

    it "changes cost traps based on buildings" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      assert_not_nil @game.room.available_crafts[:trap], "Traps available to craft?"
      @game.room.craft(:trap)
      assert @game.buildings[:trap], 1, "Trap crafted?"
      assert @game.room.crafts[:trap].cost[:wood], 15, "Price increased?"
    end

    it "available crafts are available when half the wood is reached" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]
      @game.room.builder_ready
      assert @game.room.begining_of_game, false
      @game.room.tick
      assert_not_nil @game.room.available_crafts[:trap]
      assert @game.history.select { |h| h.start_with?("builder says she can make traps") }.count, 1
      @game.room.tick
      assert @game.history.select { |h| h.start_with?("builder says she can make traps") }.count, 1
    end

    it "isn't available when under half wood cost" do
      @game.stores[:wood] = (@game.room.crafts[:trap].half_wood_cost / 2) - 1
      @game.room.builder_ready
      @game.room.unlock_crafts
      assert_nil @game.room.available_crafts[:trap]
    end

    it "doesn't unlock until builder is passed opening script" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]
      @game.room.tick
      assert_nil @game.room.available_crafts[:trap]
    end
  end

  def crafting_cart
    it "crafting recorded in history" do
      @game.stores[:wood] = @game.room.crafts[:cart].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      @game.room.craft(:cart)
      assert @game.history.select { |h| h.start_with?("the rickety cart will carry more wood, faster.") }.count, 1
    end

    it "crafting cart, lets you collect wood faster" do
      @game.stores[:wood] = @game.room.crafts[:cart].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      @game.room.craft(:cart)
      assert @game.outside.gather_wood_after, 20
    end

    it "you can't craft if you dont have enough" do
      @game.stores[:wood] = @game.room.crafts[:cart].cost[:wood]
      @game.room.builder_ready
      @game.room.unlock_crafts
      @game.stores[:wood] = 0
      assert @game.room.craft(:cart), false
      @game.outside.gather_wood
      assert @game.stores[:wood], 10
    end

    it "you can't go past the maximum for a craft" do
      @game.stores[:wood] = @game.room.crafts[:cart].cost[:wood] * 2
      @game.room.builder_ready
      @game.room.unlock_crafts
      assert @game.room.craft(:cart), true
      assert @game.room.craft(:cart), false
    end
  end

  def define_tests
    unlocking_crafts_some_of_which_require_huts
    crafting_cart
  end
end
