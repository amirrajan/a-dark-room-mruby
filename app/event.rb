class Event
  @@stub_roll_value = nil
  attr_accessor :current_scene, :scenes, :stores, :history

  def initialize stores
    @stores = stores
    @current_scene = :start
  end

  def self.stub_roll with_value
    @@stub_roll_value = with_value
  end

  def string_for cost
    cost.keys.map { |material| "#{cost[material]} #{material.gsub("_", " ")}" }.join(", ")
  end

  def info message
    @history << message if @history
  end

  def apply_rewards parent_scene
    return if @current_scene == :end

    reward = scenes[@current_scene][:reward]

    reward_proc = scenes[@current_scene][:reward_proc]

    cost = cost_entry @current_scene, parent_scene

    if cost
      info "lost: #{string_for(cost)}."

      cost.keys.each do |key|
        @stores[key] ||= 0
        @stores[key] -= cost[key]
      end
    end

    if reward
      info "received: #{string_for(reward)}."

      reward.keys.each do |key|
        @stores[key] ||= 0
        @stores[key] += reward[key]
      end
    end

    if reward_proc
      reward_proc.call
    end
  end

  def cost_entry option, from_scene = scenes[@current_scene]
    if scenes[option] and scenes[option][:cost]
      return scenes[option][:cost]
    end

    if from_scene and
      from_scene[:options] and
      from_scene[:options][option] and
      from_scene[:options][option][:next_scene_cost]
      return from_scene[:options][option][:next_scene_cost]
    end

    return nil
  end

  def cost option, from_scene = scenes[@current_scene]
    result = cost_entry option, from_scene

    return "" if !result

    return @stores.cost_string result
  end

  def afford? option, from_scene = scenes[@current_scene]
    result = cost_entry option, from_scene

    return true if !result

    @stores.afford? result
  end

  def scene_changed

  end

  def change_scene scene
    if scene == :end
      @current_scene = :end

      return
    end

    next_scene = scenes[@current_scene][:options][scene][:next_scene]

    if next_scene == :clear
      on_clear

      @current_scene = :end

      return
    end

    return false if !afford? scene

    parent_scene = scenes[@current_scene]

    if !next_scene.is_a? Hash
      @current_scene = next_scene
    else
      result = roll

      winning_scene_key = next_scene.keys.select { |k| k >= result }.first

      @current_scene = next_scene[winning_scene_key]
    end

    apply_rewards parent_scene

    scene_changed

    true
  end

  def roll
    @@stub_roll_value || rand
  end

  def self.title name

  end
end
