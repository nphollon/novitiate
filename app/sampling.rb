require 'inline'

module AudioSampling
  inline do |binding|
    binding.include '"math.h"'
    binding.add_static 'PI', Math::PI, 'double'
    binding.c <<-EOC
      double sample_sine(double phase) {
        return sin(phase * 2 * PI);
      }
      EOC
    binding.c <<-EOC
      double sample_square(double phase) {
        return (phase < 0.5) ? -1 : 1;
      }
      EOC
    binding.c <<-EOC
      double sample_triangle(double phase) {
        return (phase < 0.5) ? (4*phase - 1) : (3 - 4*phase);
      }
      EOC
    binding.c <<-EOC
      double sample_sawtooth(double phase) {
        return 2*phase - 1;
      }
      EOC
    binding.c <<-EOC
      double sample_smooth_square(double phase) {
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
    binding.c <<-EOC
      double sample_smooth_sawtooth(double phase) {
        if (phase < 0.025)
          return -40 * phase;
        else if (phase < 0.975)
          return 2/0.95 * (phase - 0.025) - 1;
        else
          return -40 * (phase - 0.975) + 1;
      }
      EOC
    binding.c <<-EOC
      double get_phase(double time, double frequency) {
        return time*frequency - floor(time*frequency);
      }
      EOC
  end
end