require_relative './fourier_series'

class FourierModulator
  attr_reader :lfo, :oscillator, :modulation_amount
  private :lfo, :oscillator

  def initialize(fundamental, oscillator)
    @oscillator = oscillator
    @lfo = FourierSeries.new fundamental
    @modulation_amount = 0
  end

  def sample(time_step)
    oscillator.sample(time_step) * (1 - modulation_amount + modulation_amount*lfo.sample(time_step))
  end

  def modulation_amount=(new_amount)
    if new_amount > 1
      @modulation_amount = 1
    elsif new_amount < 0
      @modulation_amount = 0
    else
      @modulation_amount = new_amount
    end
  end

  def lfo_fundamental
    lfo.fundamental
  end

  def lfo_fundamental=(new_fundamental)
    lfo.fundamental = new_fundamental
  end

  def lfo_bandwidth_limit
    lfo.bandwidth_limit
  end

  def lfo_bandwidth_limit=(new_bandwidth_limit)
    lfo.bandwidth_limit = new_bandwidth_limit
  end

  def lfo_coefficients
    lfo.coefficients
  end

  def lfo_coefficients=(new_coefficients)
    lfo.coefficients = new_coefficients
  end

  def set_lfo_waveform(waveform, precision)
    lfo.set_to(waveform, precision)
  end
end