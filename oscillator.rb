require_relative './waveform'

class Oscillator
  include Waveform

  attr_reader :waveform, :wave_setting, :frequency_setting, :min_frequency, :max_frequency

  def initialize(min_freq, max_freq, init_freq_setting)
    @min_frequency = min_freq
    @max_frequency = max_freq
    @wave_setting = :sine
    @waveform = SineWave.new(440.0)
    self.frequency_setting = init_freq_setting
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
    raise RangeError, "oscillator frequency setting must be between 0 and 1." unless (0..1).include?(new_setting)
    @frequency_setting = new_setting
    @waveform.frequency = min_frequency * (max_frequency/min_frequency)**new_setting
  end

  def frequency
    @waveform.frequency
  end

  def frequency=(new_frequency)
    self.frequency_setting = Math.log(new_frequency/min_frequency) / Math.log(max_frequency/min_frequency)
  end
end