class Filter
  attr_reader :level, :resonance_amount

  def initialize(sampleable)
    @filtered = sampleable
    @level = 0
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

  def sample(duration)
    filtered.sample(duration)
  end

  private
    attr_reader :filtered
end