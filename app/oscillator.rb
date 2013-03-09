require_relative './waveform'

class Oscillator
  include Waveform

  attr_reader :waveform, :wave_setting, :frequency_setting, :min_frequency, :max_frequency

  def initialize(min_freq, max_freq, smooth=false)
    @min_frequency = min_freq
    @max_frequency = max_freq
    @wave_setting = :sine
    @time = 0
    @waveform = SineWave.new(440.0)

    self.frequency_setting = 0.5

    @waveform_hash = if smooth
      { sine: SineWave, triangle: TriangleWave, square: SmoothSquareWave, sawtooth: SmoothSawtoothWave }
    else
      { sine: SineWave, triangle: TriangleWave, square: SquareWave, sawtooth: SawtoothWave }
    end
  end

  def sample(time_step)
    @time += time_step
    waveform.value_at(@time)
  end

  def wave_setting=(new_setting)
    if @waveform_hash.has_key?(new_setting)
      @wave_setting = new_setting
      @waveform = @waveform_hash[new_setting].new( frequency )
    end
  end

  def frequency_setting=(new_setting)
    if new_setting > 1
      @frequency_setting = 1
    elsif new_setting < 0
      @frequency_setting = 0
    else
      @frequency_setting = new_setting
    end
    waveform.frequency = min_frequency * (max_frequency/min_frequency)**frequency_setting
  end

  def frequency
    waveform.frequency
  end

  def frequency=(new_frequency)
    self.frequency_setting = Math.log(new_frequency/min_frequency) / Math.log(max_frequency/min_frequency)
  end
end