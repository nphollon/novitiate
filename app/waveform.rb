require 'inline'
require_relative './sampling'

module Waveform
	class Waveform
    include AudioSampling

		attr_reader :frequency

		def initialize(frequency)
			@frequency = frequency
		end

    def frequency=(new_frequency)
      raise RangeError if new_frequency <= 0
      @frequency = new_frequency
    end

    def value_at(time)
      raise NotImplementedError
    end
	end


  class SineWave < Waveform
    def value_at(time)
      sample_sine(self.get_phase(time))
    end
  end

  class TriangleWave < Waveform
    def value_at(time)
      sample_triangle(self.get_phase(time))
    end
  end

  class SquareWave < Waveform
    def value_at(time)
      sample_square(self.get_phase(time))
    end
  end

  class SawtoothWave < Waveform
    def value_at(time)
      sample_sawtooth(self.get_phase(time))
    end
  end

  class SmoothSquareWave < SquareWave
    def value_at(time)
      sample_smooth_square(self.get_phase(time))
    end
  end

  class SmoothSawtoothWave < SawtoothWave
    def value_at(time)
      sample_smooth_sawtooth(self.get_phase(time))
    end
  end
end