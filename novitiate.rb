require_relative './waveform'

class Novitiate
  include Waveform

  attr_reader :wave_setting, :gain, :waveform, :frequency_setting

  def initialize
    @wave_setting = :sine
    @gain = 1.0
    @waveform = SineWave.new(440)
    self.frequency_setting = 0.5
  end

  def wave_setting=(new_setting)
    @wave_setting = new_setting
    @waveform = {
      sine: SineWave,
      triangle: TriangleWave,
      square: SquareWave,
      sawtooth: SawtoothWave
      }[new_setting].new( frequency )
  end

  def frequency_setting=(new_setting)
    raise RangeError, "Frequency setting must be between 0 and 1." unless (0..1).include?(new_setting)
    @frequency_setting = new_setting
    @waveform.frequency = 2 * 10 ** (3*new_setting + 1)
  end

  def frequency
    @waveform.frequency
  end

  def turn_on
  end

  def turn_off
  end

  def silent?
    true
  end
end