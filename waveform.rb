module Waveform
	class Waveform
		attr_accessor :frequency

		def initialize(frequency)
			@frequency = frequency
		end

		def eval(phase)
      0
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
end