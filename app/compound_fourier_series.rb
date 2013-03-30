require 'inline'
require_relative './fourier_series'

class CompoundFourierSeries
  inline do |builder|
    builder.add_static 'PI', Math::PI, 'double'
    builder.include '"math.h"'

    builder.prefix <<-EOC
      typedef struct CompoundFourierSeries {
        VALUE component1;
        VALUE component2;
        double phase1;
        double phase2;
      } CompoundFourierSeries;

      void mark_compound_fourier_series(CompoundFourierSeries *cfs) {
        rb_gc_mark(cfs->component1);
        rb_gc_mark(cfs->component2);
      }

      void free_compound_fourier_series(CompoundFourierSeries *cfs) {
        free(cfs);
      }

      CompoundFourierSeries * get_compound_fourier_series(VALUE self) {
        CompoundFourierSeries *cfs;
        Data_Get_Struct(self, CompoundFourierSeries, cfs);
        return cfs;
      }

      void get_coefficients(VALUE fs, unsigned long index, double *odd, double *even) {
        *odd = NUM2DBL( rb_funcall(fs, rb_intern("odd_coefficient"), 1, INT2FIX(index)) );
        *even = NUM2DBL( rb_funcall(fs, rb_intern("even_coefficient"), 1, INT2FIX(index)) );
      }

      void increment_phases(CompoundFourierSeries *cfs, double time_step) {
        cfs->phase1 += time_step * NUM2DBL( rb_funcall(cfs->component1, rb_intern("fundamental"), 0) );
        cfs->phase2 += time_step * NUM2DBL( rb_funcall(cfs->component2, rb_intern("fundamental"), 0) );
      }

      double term(CompoundFourierSeries *cfs, unsigned long i, unsigned long j) {
        double a, b, c, d;
        get_coefficients(cfs->component1, i, &a, &b);
        get_coefficients(cfs->component2, j, &c, &d);
        return (a*d + b*c) * sin(2*PI * ((i+1)*cfs->phase1 + (j+1)*cfs->phase2)) +
               (b*d - a*c) * cos(2*PI * ((i+1)*cfs->phase1 + (j+1)*cfs->phase2)) +
               (a*d - b*c) * sin(2*PI * ((i+1)*cfs->phase1 - (j+1)*cfs->phase2)) +
               (b*d + a*c) * cos(2*PI * ((i+1)*cfs->phase1 - (j+1)*cfs->phase2));
      }
    EOC

    builder.c_singleton <<-EOC
      VALUE new(VALUE component1, VALUE component2) {
        CompoundFourierSeries *cfs;
        cfs = malloc(sizeof(CompoundFourierSeries));
        cfs->component1 = component1;
        cfs->component2 = component2;
        cfs->phase1 = 0;
        cfs->phase2 = 0;
        return Data_Wrap_Struct(self, mark_compound_fourier_series, free_compound_fourier_series, cfs);
      }
    EOC

    builder.c <<-EOC
      VALUE components() {
        CompoundFourierSeries *cfs = get_compound_fourier_series(self);
        return rb_ary_new3(2, cfs->component1, cfs->component2);
      }
    EOC

    builder.c <<-EOC
      double sample(double time_step) {
        CompoundFourierSeries *cfs = get_compound_fourier_series(self);
        unsigned long max_i = FIX2ULONG( rb_funcall(cfs->component1, rb_intern("max_coeff_index"), 0) );
        unsigned long max_j = FIX2ULONG( rb_funcall(cfs->component2, rb_intern("max_coeff_index"), 0) );
                
        increment_phases(cfs, time_step);

        double sum = 0;
        unsigned long i, j;
        for (i = 0; i < max_i; i++) {
          for (j = 0; j < max_j; j++) {
            sum += term(cfs, i, j);
          }
        }
        return 0.5 * sum;
      }
    EOC
  end
end