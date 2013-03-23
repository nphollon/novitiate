require_relative '../../ruby-portaudio/portaudio'

class Speaker
  attr_reader :gain, :mute, :buffer_size, :device, :stream, :time_step

  def initialize(options = {})
    @buffer_size = options[:buffer_size] || 256
    @mute = options[:mute] || false
    self.gain = 1.0
    @device = PortAudio::Device.default_output_device
    @stream = device.open_stream(frames_per_buffer: @buffer_size, mute: @mute)
    @time_step = stream.sample_rate**-1
  end

  def play(duration, sampleable)
    stream.start
    time = 0
    while time < duration
      stream.write do
        gain * sampleable.sample(time_step)
      end
      time += buffer.length * time_step
    end
    stream.stop
  end

  def buffer
    stream.buffer
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
end