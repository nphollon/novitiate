require 'inline'

class Waveform
  inline do |builder|
    builder.include '"math.h"'

    builder.prefix <<-EOC
      typedef struct Waveform {
        double frequency;
      } Waveform;
    EOC

    builder.c_singleton <<-EOC
      VALUE new(double frequency) {
        Waveform *wav;
        wav = malloc(sizeof(Waveform));
        wav->frequency = frequency;
        return Data_Wrap_Struct(self, 0, free, wav);
      }
    EOC

    builder.c <<-EOC
      double sample(double time) { 
        VALUE phase = rb_funcall(self, rb_intern("phase"), 1, rb_float_new(time));
        return NUM2DBL( rb_funcall(self, rb_intern("value_at_phase"), 1, phase) );
      }      
    EOC

    builder.c <<-EOC
      double value_at_phase(double phase) {
        rb_raise(rb_eNotImpError, "Method must be overridden by descendant.");
        return 0 * phase;
      }
    EOC

    builder.c <<-EOC
      double phase(double time) {
        double frequency = NUM2DBL( rb_funcall(self, rb_intern("frequency"), 0) );
        return time*frequency - floor(time*frequency);
      }
    EOC

    builder.struct_name = "Waveform"
    builder.reader :frequency, 'double'
    builder.c <<-EOC
      void frequency_equals(double new_frequency) {
        if (new_frequency <= 0)
          rb_raise(rb_eRangeError, "Frequency must be greater than 0 Hz.");

        Waveform *wav;
        Data_Get_Struct(self, Waveform, wav);
        wav->frequency = new_frequency;
      }
    EOC
  end
end


class SineWave < Waveform
  inline do |builder|
    builder.add_static 'PI', Math::PI, 'double'
    builder.include '"math.h"'
    builder.c <<-EOC
      double value_at_phase(double phase) {
        return sin(phase * 2 * PI);
      }
    EOC
  end
end

class TriangleWave < Waveform
  inline do |builder|
    builder.c <<-EOC
      double value_at_phase(double phase) {
        return (phase < 0.5) ? (4*phase - 1) : (3 - 4*phase);
      }
    EOC
  end
end

class SquareWave < Waveform
  inline do |builder|
    builder.c <<-EOC
      double value_at_phase(double phase) {
        return (phase < 0.5) ? -1 : 1;        
      }
    EOC
  end
end

class SawtoothWave < Waveform
  inline do |builder|
    builder.c <<-EOC
      double value_at_phase(double phase) {
        return 2*phase - 1;
      }
    EOC
  end
end

class SmoothSquareWave < SquareWave
  inline do |builder|
    builder.c <<-EOC
      double value_at_phase(double phase) {
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
  inline do |builder|
    builder.c <<-EOC
      double value_at_phase(double phase) {
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