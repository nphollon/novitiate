module Waveform
	class Waveform
		attr_reader :frequency

		def initialize(frequency)
			@frequency = frequency
		end

		def eval(phase)
      raise NotImplementedError
		end

    def frequency=(new_frequency)
      raise RangeError if new_frequency <= 0
      @frequency = new_frequency
    end

    def value_at(time)
      eval( (time*frequency).modulo(1) )
    end
	end


  class SineWave < Waveform
    def eval(phase)
      Math.sin( phase * 2*Math::PI )
    end
  end

  class TriangleWave < Waveform
    def eval(phase)
      (phase < 0.5) ? 4*phase - 1 : 3 - 4*phase
    end
  end

  class SquareWave < Waveform
    def eval(phase)
      (phase < 0.5) ? -1 : 1
    end
  end

  class SawtoothWave < Waveform
    def eval(phase)
      2*phase - 1
    end
  end

  class SmoothSquareWave < SquareWave
    def eval(phase)
      case phase
      when (0..0.05)
        -40.0 * phase + 1
      when (0.5..0.55)
        40.0 * (phase-0.5) - 1
      else
        super phase
      end
    end
  end

  class SmoothSawtoothWave < SawtoothWave
    def eval(phase)
      case phase
      when (0..0.025)
        -40.0 * phase
      when (0.975..1)
        -40.0 * (phase - 0.975) + 1
      else
        2/0.95 * (phase - 0.025) - 1
      end
    end
  end
end