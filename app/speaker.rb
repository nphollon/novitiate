require_relative '../../ruby-portaudio/lib/portaudio'

class Speaker
  attr_reader :buffer, :gain, :output, :buffer_size

  def initialize(options = {})
    @buffer_size = options[:buffer_size] || 256
    @buffer = PortAudio::SampleBuffer.new(format: :float32, frames: @buffer_size)
    @output = options[:output] || :default
    self.gain = 1.0
  end

  def turn_on
    PortAudio.init
    @device = PortAudio.default_output_device
    @stream = @device.open_stream(format: :float32, frames: @buffer_size)
    @time_step = @device.default_sample_rate**-1
  end

  def turn_off
    @device = nil
    @stream = nil
    @time_step = nil
    PortAudio.terminate
  end

  def play(duration, sampleable)
    @stream.start

    time = 0
    while time < duration
      
      fill_buffer(sampleable)
      @stream << @buffer unless @output == :mute

      yield time
      time += @buffer.frames * @time_step
    end

    @stream.stop
  end

  def fill_buffer(sampleable)
    buffer.fill do
      gain * sampleable.sample(self.time_step)
    end
  end

  def device
    @device || raise_not_turned_on_error
  end

  def stream
    @stream || raise_not_turned_on_error
  end

  def time_step
    @time_step || raise_not_turned_on_error
  end

  def gain=(new_gain)
    if new_gain > 1
      @gain = 1.0
    elsif new_gain < 0
      @gain = 0.0
    else
      @gain = new_gain
    end
      
  end

  private
  def raise_not_turned_on_error
    raise PortAudio::APIError, "Speaker not turned on"
  end
end