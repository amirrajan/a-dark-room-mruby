class Income
  include Debugging

  attr_accessor :current_tick

  def initialize
    @current_tick = 0
  end

  def after
    10
  end

  def tick_reached?
    return after == @current_tick
  end

  def reset_tick
    @current_tick = 0
  end

  def can_produce? total_stores
    result = true

    stores.keys.each do |store|
      if stores[store] < 0
        result = false if (total_stores[store] || 0) < stores[store].abs
      end
    end

    result
  end

  def apply worker_count, to_stores, transfer_to = nil
    @current_tick += 1

    return if !tick_reached?

    worker_count.times do
      next if !can_produce? to_stores

      stores.keys.each do |store|
        to_stores[store] ||= 0
        to_stores[store] += stores[store] * multiplier

        next if !transfer_to

        transfer_to[store] ||= 0
        transfer_to[store] -= stores[store]
      end
    end

    reset_tick
  end
end

class Thieves < Income
  def stores
    { :wood => -1, :fur => -1, :meat => -1 }
  end

  def after
    1
  end

  def can_produce? total_stores
    return true if (total_stores[:wood] || 0) > 0
    return true if (total_stores[:fur] || 0) > 0
    return true if (total_stores[:meat] || 0) > 0

    return false
  end

  def apply worker_count, to_stores, transfer_to = nil
    @current_tick += 1

    return if !tick_reached?

    worker_count.times do
      next if !can_produce? to_stores

      stores.keys.each do |store|
        to_stores[store] ||= 0
        next if to_stores[store] <= 0

        to_stores[store] += stores[store]

        next if !transfer_to

        transfer_to[store] ||= 0
        transfer_to[store] -= stores[store]
      end
    end

    reset_tick
  end
end

class Gatherer < Income
  def stores
    { :wood => 1 }
  end
end

class Hunter < Income
  def stores
    { :fur => 1, :meat => 1 }
  end
end

class Trapper < Income
  def apply worker_count, to_stores, transfer_to = nil
    if (to_stores[:bait] || 0) >= 1000
      to_stores[:bait] = 1000
      return
    end

    super
  end

  def stores
    { :meat => -1, :bait => 1 }
  end
end

class Tanner < Income
  def stores
    { :fur => -5, :leather => 1 }
  end
end

class Charcutier < Income
  def stores
    { :meat => -5, :wood => -5, :cured_meat => 1 }
  end
end

class Steelworker < Income
  def stores
    { :iron => -1, :coal => -1, :steel => 1 }
  end
end

class Armourer < Income
  def stores
    { :steel => -1, :sulphur => -1, :bullets => 1 }
  end
end

class IronMiner < Income
  def stores
    { :cured_meat => -1, :iron => 1 }
  end
end

class CoalMiner < Income
  def stores
    { :cured_meat => -1, :coal => 1 }
  end
end

class SulphurMiner < Income
  def stores
    { :cured_meat => -1, :sulphur => 1 }
  end
end
