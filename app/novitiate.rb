require_relative './speaker'
require_relative './oscillator'
require_relative './modulator'
require_relative './envelope'
require_relative './filter'
require_relative '../../ruby-portaudio/lib/portaudio'

class Novitiate
  def initialize(renderer = Speaker.new)
    @renderer = renderer
    @oscillator = Oscillator.new(20, 20_000)
    @modulator = Modulator.new(@oscillator, 0.1, 100, smooth = true)
    @filter = Filter.new(@modulator)
  end

  def turn_on
    renderer.turn_on
  end

  def turn_off
    renderer.turn_off
  end

  def fire_envelope
    renderer.play(1e-10, Envelope.new) {}
  end

  def play_oscillator(duration)
    renderer.play(duration, oscillator) {}
  end

  def play_modulator(duration)
    renderer.play(duration, modulator) {}
  end

  def play_filter(duration)
    renderer.play(duration, filter) {}
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

  def filter_amount
    filter.level
  end

  def filter_amount=(new_amount)
    filter.level = new_amount
  end

  def resonance_amount
    filter.resonance_amount
  end

  def resonance_amount=(new_amount)
    filter.resonance_amount = new_amount
  end

  private
    attr_reader :oscillator, :renderer, :modulator, :filter
end