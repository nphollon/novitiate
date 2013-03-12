require 'inline'

module Waveform
	class Waveform
		attr_reader :frequency

		def initialize(frequency)
			@frequency = frequency
		end

    def frequency=(new_frequency)
      raise RangeError if new_frequency <= 0
      @frequency = new_frequency
    end

    def value_at(time)
      compute_value(time, self.frequency)
    end

    def compute_value(time, frequency)
      raise NotImplementedError
    end
	end


  class SineWave < Waveform
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          return sin(phase * 2 * PI);
        }
      EOC
    end
  end

  class TriangleWave < Waveform
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          return (phase < 0.5) ? (4*phase - 1) : (3 - 4*phase);
        }
      EOC
    end
  end

  class SquareWave < Waveform
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          return (phase < 0.5) ? -1 : 1;
        }
      EOC
    end
  end

  class SawtoothWave < Waveform
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          return 2*phase - 1;
        }
      EOC
    end
  end

  class SmoothSquareWave < SquareWave
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          if (phase < 0.05)
            return -40*phase + 1;
          else if (phase < 0.5)
            return -1;
          else if (phase < 0.55)
            return 40*(phase-0.5) - 1;
          else
            return 1;
        }
      EOC
    end
  end

  class SmoothSawtoothWave < SawtoothWave
    inline do |binding|
      binding.add_static 'PI', Math::PI, 'double'
      binding.include '"math.h"'
      binding.c <<-EOC
        double compute_value(double time, double frequency) {
          double phase = time*frequency - floor(time*frequency);
          if (phase < 0.025)
            return -40 * phase;
          else if (phase < 0.975)
            return 2/0.95 * (phase - 0.025) - 1;
          else
            return -40 * (phase - 0.975) + 1;
        }
      EOC
    end
  end
end