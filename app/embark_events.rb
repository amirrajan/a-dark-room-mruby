class TheScout < Event
  title "the scout"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.solo_run?

    @game.active_module == :embark and
      @game.stores[:fur] and
      @game.stores[:fur] >= 200 and
      @game.active_module != :world and
      !@game.world.cleared?
  end

  def init_scenes
    end_buy_text = [
      "business is done.",
      "she turns and walks away without saying a word."
    ]

    leave_option = { :leave => { :next_scene => :end } }

    result = {
      :start => {
        :text => [
          "the scout says she's been all over.",
          "willing to talk about it, for a price."
        ],
        :options => {
          :buy_map => { :next_scene => :buy_map },
        }
      },
      :buy_map => {
        :text => end_buy_text,
        :cost => { :fur => 200 },
        :reward_proc => lambda do
          revealed = @game.world.reveal_random
          @game.history << "revealed area to the #{@game.world.compass_direction_string revealed}."
        end,

        :options => leave_option
      },
      :learn_skill =>  {
        :text => end_buy_text,
        :cost => { :fur => 1000, :teeth => 20 },
        :reward_proc => lambda { @game.add_perk :scout },
        :options => leave_option
      }
    }

    if !@game.has_perk?(:scout)
      result[:start][:options][:learn_skill] = { :next_scene => :learn_skill }
    end

    result[:start][:options][:no_thanks] = { :next_scene => :end }

    @scenes = result
  end
end

class LocketReveals < Event
  title "locket reveals"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return true if @game.solo_run? and @game.active_module == :embark

    return false
  end

  def init_scenes
    leave_option = { :leave => { :next_scene => :end } }

    result = {
      :start => {
        :text => ["the locket flashes violently."],
        :options => {
          :continue => { :next_scene => :continue },
        }
      },
      :continue => {
        :text => ["dancing lights paint the world, beyond the forest."],
        :reward_proc => lambda do
          revealed = @game.world.reveal_random
          @game.history << "revealed area to the #{@game.world.compass_direction_string revealed}."
        end,
        :options => leave_option
      }
    }

    @scenes = result
  end
end

class TheMaster < Event
  title "the master"

  def initialize game
    @game = game
    super game.stores
  end

  def is_available?
    return false if @game.active_module == :world
    return false if @game.active_module == :ship

    if @game.has_perk?(:evasive) and @game.has_perk?(:precise) and @game.has_perk?(:barbarian)
      return false
    end

    return false if !@game.stores[:compass]
    return false if !@game.stores[:cured_meat]
    return false if !@game.stores[:fur]
    return false if !@game.stores[:torch]
    return false if @game.stores[:fur] < 100

    true
  end

  def init_scenes
    leave_option = { :leave => { :next_scene => :end } }

    result = {
      :start => {
        :text => [
          'an old wanderer arrives.',
          'he smiles warmly and asks for lodgings for the night.'
        ],
        :options => {
          :yes => { :next_scene => :yes },
          :no => { :next_scene => :end }
        }
      },
      :yes => {
        :text => [
          "in exchange, the wanderer offers his wisdom."
        ],
        :cost => { :cured_meat => 50, :fur => 100, :torch => 1 },
        :options => { }
      },
      :evasion => {
        :text => [ "the master teaches evasion." ],
        :reward_proc => lambda { @game.add_perk :evasive },
        :options => leave_option
      },
      :precision => {
        :text => [ "the master teaches precision." ],
        :reward_proc => lambda { @game.add_perk :precise },
        :options => leave_option
      },
      :strength => {
        :text => [ "the master teaches strength." ],
        :reward_proc => lambda { @game.add_perk :barbarian },
        :options => leave_option
      }
    }

    if !@game.has_perk?(:evasive)
      result[:yes][:options][:evasion] = { :next_scene => :evasion }
    end

    if !@game.has_perk?(:precise)
      result[:yes][:options][:precision] = { :next_scene => :precision }
    end

    if !@game.has_perk?(:barbarian)
      result[:yes][:options][:strength] = { :next_scene => :strength }
    end

    @scenes = result
  end
end
