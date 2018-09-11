class OutsideTests < Tests
  def define_tests
    before do
      @game = Game.new
      # @game.load
      # @game.game_state.clear
      @game.room.unlock_forest
      @game.outside.roll_override = 0.4
    end

    it "adds 10 wood when gathering" do
      @game.stores[:wood] = 0
      @game.outside.gather_wood
      assert @game.stores[:wood], 10
    end

    it "there is a cooldown for gathering wood" do
      @game.outside.gather_wood
      assert @game.outside.can_gather_wood?, false
      @game.outside.gather_wood_after.times { @game.tick }
      assert @game.outside.can_gather_wood?, true
    end

    it "ignores attempts to gather wood if cool down hasn't occurred" do
      @game.stores[:wood] = 0
      @game.outside.gather_wood
      @game.outside.gather_wood
      assert @game.stores[:wood], 10
    end

    it "checking traps has a cooldown" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]

      @game.room.builder_ready

      @game.room.unlock_crafts

      @game.room.craft(:trap)

      assert @game.outside.check_traps, true

      assert @game.outside.check_traps, false

      @game.outside.check_traps_after.times { @game.tick }

      assert @game.outside.check_traps, true
    end

    it "allows user to collect thing from traps" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]

      @game.room.builder_ready

      @game.room.unlock_crafts

      @game.room.craft(:trap)

      assert @game.outside.can_check_traps?, true

      @game.outside.check_traps

      assert @game.stores[:fur], 2

      assert(@game.history.select { |h| h.start_with?("1 traps contain") }.count, 1)
    end

    it "uses bait count for traps if bait is at a higher number" do
      @game.stores[:wood] = @game.room.crafts[:trap].cost[:wood]

      @game.room.builder_ready

      @game.room.unlock_crafts

      @game.room.craft(:trap)

      assert @game.outside.can_check_traps?, true

      bait_count = 3

      @game.stores[:bait] = bait_count

      @game.outside.check_traps

      assert @game.stores[:fur], bait_count * 2

      assert(@game.history.select { |h| h.start_with?("3 baited traps contain") }.count, 1)
    end
  end
end
