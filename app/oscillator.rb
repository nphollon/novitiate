require 'inline'
require_relative './waveform'

class Oscillator
  attr_reader :wave_setting, :frequency_setting, :min_frequency, :max_frequency, :frequency, :waveform
  attr_accessor :time

  def initialize(min_freq, max_freq, smooth=false)
    @min_frequency = min_freq
    @max_frequency = max_freq
    @wave_setting = :sine
    @waveform = SineWave.new(440)
    @time = 0

    self.frequency_setting = 0.5

    @waveform_hash = if smooth
      { sine: SineWave, triangle: TriangleWave, square: SmoothSquareWave, sawtooth: SmoothSawtoothWave }
    else
      { sine: SineWave, triangle: TriangleWave, square: SquareWave, sawtooth: SawtoothWave }
    end
  end

  inline do |builder|
    builder.c <<-EOC
      double sample(double time_step) {
        double time = NUM2DBL( rb_funcall(self, rb_intern("time"), 0) );
        time += time_step;
        rb_funcall(self, rb_intern("time="), 1, rb_float_new(time));
        VALUE wav = rb_funcall(self, rb_intern("waveform"), 0);
        VALUE wav_sample = rb_funcall(wav, rb_intern("sample"), 1, rb_float_new(time));
        return NUM2DBL(wav_sample);
      }
    EOC
  end

  def wave_setting=(new_setting)
    if @waveform_hash.has_key?(new_setting)
      @wave_setting = new_setting 
      @waveform = @waveform_hash[wave_setting].new(frequency)
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
    @frequency = min_frequency * (max_frequency/min_frequency)**frequency_setting
    @waveform.frequency = @frequency
  end

  def frequency=(new_frequency)
    self.frequency_setting = Math.log(new_frequency/min_frequency) / Math.log(max_frequency/min_frequency)
  end
end