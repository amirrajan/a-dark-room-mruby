class ToolsTests < Tests
  def define_tests
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.light_fire
      @game.room.unlock_forest
      @game.room.builder_ready
    end

    it "are locked until workshop is bought" do
      assert @game.room.available_tools.keys.count, 0
    update_stores_for @game.room.tools[:torch].cost
    update_stores_for @game.room.crafts[:workshop].cost
    @game.tick
    assert_nil @game.room.available_tools[:torch]
    @game.room.craft(:workshop)
    assert @game.room.all_materials_encountered(@game.room.tools[:torch].cost), true
    @game.tick
    assert_not_nil @game.room.available_tools[:torch]
    end
  end

  def update_stores_for cost
    cost.keys.each do |key|
      @game.stores[key] = cost[key] + 1
    end
  end
end
