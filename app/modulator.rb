require_relative './oscillator'

class Modulator < Oscillator
  attr_reader :amount

  def initialize(sampleable, *args)
    super(*args)
    @amount = 0
    @modulated = sampleable
  end

  def amount=(new_amount)
    if new_amount > 1
      @amount = 1
    elsif new_amount < 0
      @amount = 0
    else
      @amount = new_amount
    end
  end

  def sample(time_step)
    @modulated.sample(time_step) * (1 - @amount * super(time_step))
  end
end