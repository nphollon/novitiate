require_relative './waveform'

class Oscillator
  include AudioSampling

  attr_reader :wave_setting, :frequency_setting, :min_frequency, :max_frequency, :frequency

  def initialize(min_freq, max_freq, smooth=false)
    @min_frequency = min_freq
    @max_frequency = max_freq
    @wave_setting = :sine
    @time = 0

    self.frequency_setting = 0.5

    @waveform_hash = if smooth
      { sine: :sample_sine, triangle: :sample_triangle, square: :sample_smooth_square, sawtooth: :sample_smooth_sawtooth }
    else
      { sine: :sample_sine, triangle: :sample_triangle, square: :sample_square, sawtooth: :sample_sawtooth }
    end
  end

  def sample(time_step)
    @time += time_step
    send(@waveform_hash[wave_setting], get_phase(@time, frequency))
  end

  def wave_setting=(new_setting)
    @wave_setting = new_setting if @waveform_hash.has_key?(new_setting)
  end

  def frequency_setting=(new_setting)
    if new_setting > 1
      @frequency_setting = 1
    elsif new_setting < 0
      @frequency_setting = 0
    else
      @frequency_setting = new_setting
    end
    @frequency = min_frequency * (max_frequency/min_frequency)**frequency_setting
  end

  def frequency=(new_frequency)
    self.frequency_setting = Math.log(new_frequency/min_frequency) / Math.log(max_frequency/min_frequency)
  end
end