class WorldEvent < Event
  include Debugging

  attr_accessor :title, :combat_tick, :last_damage_given, :last_damage_taken

  def initialize stores
    super stores
    init_scenes
  end

  def attack_probablity
    return 0.9 if @game.has_perk?(:precise)

    0.8
  end

  def scene_changed
    if in_battle?
      scenes[@current_scene][:stunned] ||= false
      scenes[@current_scene][:stun_countdown] = 0
    end
  end

  def player_dodge
    return 0.36 if @game.has_perk?(:evasive)

    0.20
  end

  def replenishes_water?
    false
  end

  def becomes_outpost?
    false
  end

  def generates_road?
    false
  end

  def on_clear_replace_with
    nil
  end

  def loot_sample
    scene = scenes[@current_scene]

    result = { }

    loot = scene[:loot]

    loot.keys.each do |key|
      if roll < loot[key][:chance]
        result[key] = (loot[key][:min]..loot[key][:max]).to_a.sample
      end
    end

    result
  end

  def in_battle?
    scenes[@current_scene] and scenes[@current_scene][:combat]
  end

  def just_loot?
    !in_battle? and scenes[@current_scene][:loot]
  end

  def battle_complete?
    scenes[@current_scene][:health] <= 0
  end

  def damage_with_perk attack_type
    damage = attack_type.damage

    if @game.has_perk?(:boxer) and attack_type.weapon == :fists
      damage = (damage * 2)
    end

    if @game.has_perk?(:martial_artist) and attack_type.weapon == :fists
      damage = (damage * 3)
    end

    if @game.has_perk?(:unarmed_master) and attack_type.weapon == :fists
      damage = (damage * 3)
    end

    if @game.has_perk?(:barbarian) and attack_type.melee?
      damage = (damage * 1.5).floor
    end

    damage * multiplier
  end

  def attack attack_type
    attacked = false
    missed = false
    damage = damage_with_perk attack_type

    combat_scene = scenes[@current_scene]

    if attack_type.can_use?
      attacked = true
      missed = roll > attack_probablity

      if !missed
        if attack_type.weapon == :bolas
          combat_scene[:stunned] = true
          combat_scene[:stun_countdown] = 4
        else
          combat_scene[:health] -= damage
          @last_damage_given = damage
        end
      end

      if attack_type.weapon == :fists
        @game.world.punch_count += 1
      end

      attack_type.used
    end

    Struct.new(:attacked, :missed, :damage).new(attacked, missed, damage)
  end

  def tick_all_attacks
    weapons = @game.world.attacks
    weapons.keys.each do |key|
      weapons[key].tick
    end
  end

  def tick
    return if !in_battle?

    @combat_tick += 1

    attack_result = enemy_attack

    tick_all_attacks

    attack_result
  end

  def enemy_attack
    combat_scene = scenes[@current_scene]
    attacked = false
    missed = false
    stunned = false
    damage = combat_scene[:damage]

    if combat_scene[:stunned]
      combat_scene[:stun_countdown] -= 1
      stunned = true
    end

    if combat_scene[:stun_countdown] <= 0
      combat_scene[:stunned] = false
    end

    if !stunned
      if cool_down_complete combat_scene[:attack_delay]
        missed = roll <= player_dodge

        if !missed
          @game.world.decrement_hp damage
          @last_damage_taken = damage
        end

        attacked = true
      end
    end

    Struct.new(:attacked, :missed, :damage).new(attacked, missed, damage)
  end

  def cool_down_complete attack_delay
    (@combat_tick % scenes[@current_scene][:attack_delay]) == 0
  end

  def on_clear
    x = @game.world.x
    y = @game.world.y

    if becomes_outpost?
      @game.world.landmarks[[x,y]] = :outpost
      @game.world.draw_road
    elsif on_clear_replace_with
      @game.world.landmarks[[x,y]] = on_clear_replace_with
    else
      @game.world.clear_landmark x, y
    end

    if generates_road?
      @game.world.draw_road
    end

    @game.world.event = nil
  end
end
