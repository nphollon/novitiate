require_relative './waveform'
require_relative '../ruby-portaudio/lib/portaudio'

class Novitiate
  include Waveform

  attr_reader :buffer, :step,
    :osc_wave_setting, :osc_waveform, :osc_freq_setting, 
    :mod_wave_setting, :mod_waveform, :mod_freq_setting
  attr_accessor :gain

  def initialize
    @gain = 1.0
    @phase = 0.0

    @osc_wave_setting = :sine
    @osc_waveform = SineWave.new(440.0)
    self.osc_freq_setting = 0.5

    @mod_wave_setting = :sine
    @mod_waveform = SineWave.new(440.0)
    self.mod_freq_setting = 0.0
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
      sample @osc_waveform.eval(@phase)
    end
  end

  def sample normal_value
    @gain * (2 * normal_value - 1)
  end

  def osc_wave_setting=(new_setting)
    @osc_wave_setting = new_setting
    @osc_waveform = {
      sine: SineWave,
      triangle: TriangleWave,
      square: SquareWave,
      sawtooth: SawtoothWave
      }[new_setting].new( osc_frequency )
  end

  def osc_freq_setting=(new_setting)
    raise RangeError, "oscillation frequency setting must be between 0 and 1." unless (0..1).include?(new_setting)
    @osc_freq_setting = new_setting
    @osc_waveform.frequency = 2 * 10 ** (3*new_setting + 1)
  end

  def slew_frequency(slew_rate) # in octaves per second
    self.osc_freq_setting += slew_rate * Math.log10(2)/3 * @step * @buffer.frames
  end

  def osc_frequency=(new_frequency)
    self.osc_freq_setting = (Math.log10(0.5*new_frequency) - 1) / 3
  end

  def osc_frequency
    @osc_waveform.frequency
  end

  def mod_wave_setting=(new_setting)
    @mod_wave_setting = new_setting
    @mod_waveform = {
      sine: SineWave,
      triangle: TriangleWave,
      square: SquareWave,
      sawtooth: SawtoothWave
      }[new_setting].new( mod_frequency )
  end

  def mod_freq_setting=(new_setting)
    raise RangeError, "modulation frequency setting must be between 0 and 1." unless (0..1).include?(new_setting)
    @mod_freq_setting = new_setting
    @mod_waveform.frequency = 2 * 10 ** (3*new_setting + 1)
  end

  def mod_frequency=(new_frequency)
    self.mod_freq_setting = (Math.log10(0.5*new_frequency) - 1) / 3
  end

  def mod_frequency
    @mod_waveform.frequency
  end


  def playing?
    false
  end
end