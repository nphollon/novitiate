require 'waveform'
require 'portaudio'

class Novitiate
  include Waveform

  attr_reader :wave_setting, :gain, :waveform, :frequency_setting, :buffer

  def initialize
    @wave_setting = :sine
    @gain = 1.0
    @phase = 0
    @waveform = SineWave.new(440)
    self.frequency_setting = 0.5
  end

  def turn_on
    PortAudio.init
    device = PortAudio.default_output_device
    @stream = device.open_stream(format: :float32)
    @buffer = PortAudio::SampleBuffer.new(format: :float32)
    @step = device.default_sample_rate ** -1
  end

  def turn_off
    @buffer.dispose
    @stream.close
    PortAudio.terminate
  end

  def play
    @stream.start
    time = 0

    loop do
      yield time
      @stream << fill_buffer
      time += @step * @buffer.frames
    end
    
    @stream.stop
  end

  def fill_buffer
    @buffer.fill do
      @phase = (@phase + self.frequency*@step).modulo(1)
      sample @waveform.eval(@phase)
    end
  end

  def sample normal_value
    2 * normal_value - 1
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

  def frequency=(new_frequency)
    self.frequency_setting = (Math.log10(0.5*new_frequency) - 1) / 3
  end

  def slew_frequency(slew_rate) # in octaves per second
    self.frequency_setting += slew_rate * Math.log10(2)/3 * @step * @buffer.frames
  end

  def frequency
    @waveform.frequency
  end

  def playing?
    false
  end
end