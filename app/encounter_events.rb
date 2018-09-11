class EncounterEvent < WorldEvent
  def initialize game
    @game = game
    @combat_tick = 0
    super @game.world.stores
  end

  def self.title title
    define_method("title") { title }
  end

  def self.text text
    define_method("text") { text }
  end

  def self.enemy enemy
    define_method("enemy") { enemy }
  end

  def self.damage damage
    define_method("damage") { damage }
  end

  def self.health health
    define_method("health") { health }
  end

  def self.attack_delay attack_delay
    define_method("attack_delay") { attack_delay }
  end

  def self.hit hit
    define_method("hit") { hit }
  end

  def leave
    { :next_scene => :end }
  end

  def init_scenes
    @scenes = {
      :start => {
        :text => [ text ],
        :options => { :ready => { :next_scene => :ready }, }
      },
      :ready => {
        :enemy => enemy,
        :damage => damage,
        :health => health,
        :max_health => health,
        :attack_delay => attack_delay,
        :hit => hit,
        :combat => true,
        :text => [ text ],
        :loot => loot,
        :options => { :leave => leave }
      }
    }
  end
end
