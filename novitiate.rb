require_relative './waveform'

class Novitiate
  include Waveform

  attr_reader :wave_setting, :gain, :waveform, :frequency_setting

  def initialize
    @wave_setting = :sine
    @gain = 1.0
    @waveform = SineWave.new(440)
    @frequency_setting = 0.5
  end

  def wave_setting=(new_setting)
    @wave_setting = new_setting
    @waveform = {
      sine: SineWave,
      triangle: TriangleWave,
      square: SquareWave,
      sawtooth: SawtoothWave
      }[new_setting].new(440)
  end

  def turn_on
  end

  def turn_off
  end

  def silent?
    true
  end
end