require_relative './oscillator'
require_relative '../ruby-portaudio/lib/portaudio'

class Novitiate
  attr_reader :buffer, :step
  attr_accessor :gain, :modulation_amount

  def initialize
    @gain = 1.0
    @osc_phase = 0.0
    @mod_phase = 0.0

    @oscillator = Oscillator.new(20, 20_000, 0.5)
    @modulator = Oscillator.new(0.1, 100, 0.0)

    @modulation_amount = 0.0
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
    buffer.fill do
      @osc_phase = (@osc_phase + osc_frequency*step).modulo(1)
      @mod_phase = (@mod_phase + mod_frequency*step).modulo(1)
      sample
    end
  end

  def sample
    gain * sample_oscillation * sample_modulation
  end

  def sample_oscillation
    osc_waveform.eval(@osc_phase)
  end

  def sample_modulation
    1 - modulation_amount + modulation_amount*mod_waveform.eval(@mod_phase)
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

  def slew_osc_frequency(slew_rate) # in octaves per second
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

  def slew_mod_frequency(slew_rate)
    self.mod_freq_setting += slew_rate * Math.log10(2)/3 * @step * @buffer.frames
  end

  def mod_frequency
    @modulator.frequency
  end

  def mod_frequency=(new_frequency)
    @modulator.frequency = new_frequency
  end
end