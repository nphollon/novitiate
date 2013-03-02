require_relative './oscillator'
require_relative '../ruby-portaudio/lib/portaudio'

class Novitiate
  attr_reader :buffer, :step
  attr_accessor :gain

  def initialize
    @gain = 1.0
    @phase = 0.0

    @oscillator = Oscillator.new(20, 20_000, 0.5)
    @modulator = Oscillator.new(10, 100, 0.0)
  end

  def turn_on
    PortAudio.init
    @device = PortAudio.default_output_device
    @buffer = PortAudio::SampleBuffer.new(format: :float32)
    @step = @device.default_sample_rate ** -1
  end

  def turn_off
    @buffer.dispose
    PortAudio.terminate
  end

  def play
    stream = @device.open_stream(format: :float32)
    stream.start
    time = 0

    loop do
      yield time
      stream << fill_buffer
      time += @step * @buffer.frames
    end
    
    stream.stop
    stream.close
  end

  def fill_buffer
    @buffer.fill do
      @phase = (@phase + self.osc_frequency*@step).modulo(1)
      sample osc_waveform.eval(@phase)
    end
  end

  def sample normal_value
    @gain * (2 * normal_value - 1)
  end

  def osc_waveform
    @oscillator.waveform
  end

  def osc_wave_setting
    @oscillator.wave_setting
  end

  def osc_wave_setting=(new_setting)
    @oscillator.wave_setting = new_setting
  end

  def osc_freq_setting
    @oscillator.frequency_setting
  end

  def osc_freq_setting=(new_setting)
    @oscillator.frequency_setting = new_setting
  end

  def slew_frequency(slew_rate) # in octaves per second
    self.osc_freq_setting += slew_rate * Math.log10(2)/3 * @step * @buffer.frames
  end

  def osc_frequency
    @oscillator.frequency
  end

  def osc_frequency=(new_frequency)
    @oscillator.frequency = new_frequency
  end

  def mod_waveform
    @modulator.waveform
  end

  def mod_wave_setting
    @modulator.wave_setting
  end

  def mod_wave_setting=(new_setting)
    @modulator.wave_setting = new_setting
  end

  def mod_freq_setting
    @modulator.frequency_setting
  end

  def mod_freq_setting=(new_setting)
    @modulator.frequency_setting = new_setting
  end

  def mod_frequency
    @modulator.frequency
  end

  def mod_frequency=(new_frequency)
    @modulator.frequency = new_frequency
  end
end