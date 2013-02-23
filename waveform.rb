module Waveform
	class Waveform
		attr_reader :frequency

		def initialize(frequency)
			@frequency = frequency
		end

		def eval(phase)
      0
		end
	end


  class SineWave < Waveform
    def eval(phase)
      0.5 * ( 1 + Math.sin( phase * 2*Math::PI ) )
    end
  end

  class TriangleWave < Waveform
    def eval(phase)
      (phase < 0.5) ? 2*phase : 2*(1 - phase)
    end
  end

  class SquareWave < Waveform
    def eval(phase)
      (phase < 0.5) ? 0 : 1
    end
  end

  class SawtoothWave < Waveform
    def eval(phase)
      phase
    end
  end
end