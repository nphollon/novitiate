require "inline"

class FourierSeries
  inline do |builder|
    builder.include '"math.h"'
    builder.add_static 'PI', Math::PI, 'double'
    builder.add_static 'DEFAULT_COEFF_COUNT', 1, 'unsigned long'
    builder.add_static 'DEFAULT_BANDWIDTH_LIMIT', 10_000, 'double'

    builder.prefix <<-EOC
      typedef struct FourierSeries {
        double fundamental;
        unsigned long sin_coeff_count;
        unsigned long cos_coeff_count;
        double *sin_coefficients;
        double *cos_coefficients;
        double phase;
        double bandwidth_limit;
      } FourierSeries;

      FourierSeries * get_fourier_series(VALUE self) {
        FourierSeries *fs;
        Data_Get_Struct(self, FourierSeries, fs);
        return fs;
      }

      void free_fourier_series(FourierSeries *fs) {
        free(fs->sin_coefficients);
        free(fs->cos_coefficients);
        free(fs);
      }

      void mark_fourier_series(FourierSeries *fs) {}

      VALUE array_to_list(double *array, unsigned long length) {
        unsigned long i;
        VALUE list = rb_ary_new2(length);
        for (i = 0; i < length; i++)
          rb_ary_store(list, i, rb_float_new(array[i]));
        return list;
      }

      void check_length(VALUE list, double **array, unsigned long *array_length) {
        unsigned long list_length = FIX2ULONG(rb_funcall(list, rb_intern("length"), 0));
        if (list_length > *array_length) {
          *array_length = list_length;
          *array = realloc(*array, list_length * sizeof(double));
        }
      }

      void list_to_array(VALUE list, double **array, unsigned long *array_length) {
        check_length(list, array, array_length);
        unsigned long i;
        for (i = 0; i < *array_length; i++) {
          VALUE entry = rb_ary_entry(list, i);
          (*array)[i] = (entry == Qnil) ? 0 : NUM2DBL(entry);
        }
      }

      int is_harmonic_played(unsigned long i, FourierSeries *fs) {
        return (i+1)*fs->fundamental < fs->bandwidth_limit;
      }
    EOC

    builder.c_singleton <<-EOC
      VALUE new(double fundamental) {
        FourierSeries *fs = malloc(sizeof(FourierSeries));
        fs->sin_coeff_count = DEFAULT_COEFF_COUNT;
        fs->cos_coeff_count = DEFAULT_COEFF_COUNT;
        fs->sin_coefficients = malloc(fs->sin_coeff_count * sizeof(double));
        fs->cos_coefficients = malloc(fs->cos_coeff_count * sizeof(double));

        fs->fundamental = fundamental;
        fs->sin_coefficients[0] = 1;
        fs->cos_coefficients[0] = 0;
        fs->phase = 0;
        fs->bandwidth_limit = DEFAULT_BANDWIDTH_LIMIT;

        return Data_Wrap_Struct(self, mark_fourier_series, free_fourier_series, fs);
      }
    EOC

    builder.struct_name = "FourierSeries"
    builder.accessor :fundamental, "double"
    builder.accessor :bandwidth_limit, "double"

    builder.c <<-EOC
      VALUE coefficients() {
        FourierSeries *fs = get_fourier_series(self);
        VALUE sin_coeff_list = array_to_list(fs->sin_coefficients, fs->sin_coeff_count);
        VALUE cos_coeff_list = array_to_list(fs->cos_coefficients, fs->cos_coeff_count);
        return rb_ary_new3(2, sin_coeff_list, cos_coeff_list);
      }
    EOC

    builder.c <<-EOC
      void coefficients_equals(VALUE coeff_list) {
        FourierSeries *fs = get_fourier_series(self);

        VALUE sin_coeff_list = rb_ary_entry(coeff_list, 0);
        VALUE cos_coeff_list = rb_ary_entry(coeff_list, 1);

        list_to_array(sin_coeff_list, &fs->sin_coefficients, &fs->sin_coeff_count);
        list_to_array(cos_coeff_list, &fs->cos_coefficients, &fs->cos_coeff_count);
      }
    EOC

    builder.c <<-EOC
      double sample(double time_step) {
        FourierSeries *fs = get_fourier_series(self);
        fs->phase += time_step * fs->fundamental;
        double sum = 0;

        unsigned long i;
        for (i = 0; i < fs->cos_coeff_count && is_harmonic_played(i, fs); i++)
          sum += fs->sin_coefficients[i] * sin(2*PI * (i+1) * fs->phase);
        for (i = 0; i < fs->cos_coeff_count && is_harmonic_played(i, fs); i++)
          sum += fs->cos_coefficients[i] * cos(2*PI * (i+1) * fs->phase);
        return sum;
      }
    EOC
  end
end