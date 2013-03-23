require_relative './speaker'
require_relative './oscillator'
require_relative './modulator'
require_relative './envelope'
require_relative './filter'

class Novitiate
  def initialize(renderer = Speaker.new)
    @renderer = renderer
    @oscillator = Oscillator.new(20, 20_000)
    @modulator = Modulator.new(@oscillator, 0.1, 100, smooth = true)
    @filter = Filter.new(@modulator, 2)
  end

  def fire_envelope
    renderer.play(1e-10, Envelope.new) 
  end

  def play_oscillator(duration)
    renderer.play(duration, oscillator) 
  end

  def play_modulator(duration)
    renderer.play(duration, modulator) 
  end

  def play_filter(duration)
    renderer.play(duration, filter) 
  end

  def gain
    renderer.gain
  end

  def gain=(new_gain)
    renderer.gain = new_gain
  end

  def osc_wave_setting
    oscillator.wave_setting
  end

  def osc_wave_setting=(new_setting)
    oscillator.wave_setting = new_setting
  end

  def osc_frequency
    oscillator.frequency
  end

  def osc_frequency_setting
    oscillator.frequency_setting
  end

  def osc_frequency_setting=(new_setting)
    oscillator.frequency_setting = new_setting
  end

  def mod_wave_setting
    modulator.wave_setting
  end

  def mod_wave_setting=(new_setting)
    modulator.wave_setting = new_setting
  end

  def mod_frequency
    modulator.frequency
  end

  def mod_frequency_setting=(new_setting)
    modulator.frequency_setting = new_setting
  end

  def mod_frequency_setting
    modulator.frequency_setting
  end

  def mod_amount
    modulator.amount
  end

  def mod_amount=(new_amount)
    modulator.amount = new_amount
  end

  def filter_level
    filter.level
  end

  def filter_level=(new_amount)
    filter.level = new_amount
  end

  def filter_resonance
    filter.resonance
  end

  def filter_resonance=(new_amount)
    filter.resonance = new_amount
  end

  private
    attr_reader :oscillator, :renderer, :modulator, :filter
end