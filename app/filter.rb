class Filter
  attr_reader :level, :resonance_amount, :cache_size, :cache, :dt

  def initialize(sampleable, memory=1)
    @filtered = sampleable
    @level = 0
    @cache_size = memory
    @cache = [0] * memory
    @dt = 0
    @resonance_amount = 0
  end

  def level=(new_level)
    if new_level > 1
      @level = 1
    elsif new_level < 0
      @level = 0
    else
      @level = new_level
    end      
  end

  def resonance_amount=(new_amount)
    if new_amount > 1
      @resonance_amount = 1
    elsif new_amount < 0
      @resonance_amount = 0
    else
      @resonance_amount = new_amount
    end      
  end

  def sample(time_step)
    unless time_step == @dt
      empty_cache
      @dt = time_step
    end
    update_cache compute_filtered_sample(filtered.sample(time_step))
  end

  def update_cache(new_sample)
    (cache_size-1).downto(1) do |i|
      cache[i] = cache[i-1]      
    end
    cache[0] = new_sample
  end

  def empty_cache
    self.cache = [0] * cache_size
  end

  def compute_filtered_sample(unfiltered_sample)
    weighted_cache_sum = 0.0

    (0...cache_size).each do |i|
      weighted_cache_sum += filter_coeff(i) * cache[i]
    end

    level*unfiltered_sample + (1 - level)*weighted_cache_sum
  end

  def filter_coeff(index)
    index == 0 ? 1 : 0
  end
    

  private
    attr_reader :filtered
    attr_writer :cache, :dt
end