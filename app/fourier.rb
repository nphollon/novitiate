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
        unsigned long odd_coeff_count;
        unsigned long even_coeff_count;
        double *odd_coefficients;
        double *even_coefficients;
        double phase;
        double bandwidth_limit;
      } FourierSeries;

      FourierSeries * get_fourier_series(VALUE self) {
        FourierSeries *fs;
        Data_Get_Struct(self, FourierSeries, fs);
        return fs;
      }

      void free_fourier_series(FourierSeries *fs) {
        free(fs->odd_coefficients);
        free(fs->even_coefficients);
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

      void realloc_if_needed(double **array, unsigned long *array_length, unsigned long new_length) {
        if (new_length > *array_length) {
          *array_length = new_length;
          *array = realloc(*array, new_length * sizeof(double));
        }
      }

      void fit_array_to_list_size(VALUE list, double **array, unsigned long *array_length) {
        unsigned long list_length = FIX2ULONG(rb_funcall(list, rb_intern("length"), 0));
        realloc_if_needed(array, array_length, list_length);
      }

      void list_to_array(VALUE list, double **array, unsigned long *array_length) {
        fit_array_to_list_size(list, array, array_length);
        unsigned long i;
        for (i = 0; i < *array_length; i++) {
          VALUE entry = rb_ary_entry(list, i);
          (*array)[i] = (entry == Qnil) ? 0 : NUM2DBL(entry);
        }
      }

      int is_harmonic_played(unsigned long i, FourierSeries *fs) {
        return (i+1)*fs->fundamental < fs->bandwidth_limit;
      }

      double coeff_sine_wave(unsigned long i) { 
        return (i == 0) ? 1 : 0;
      }

      double coeff_triangle_wave(unsigned long i) {
        if (i%2 == 1)
          return 0;
        else
          return 8 * pow(-1, i/2) / pow(PI*(i+1), 2);
      }

      double coeff_square_wave(unsigned long i) {
        if (i%2 == 1)
          return 0;
        else
          return 4 / PI / (i+1);
      }

      double coeff_sawtooth_wave(unsigned long i) {
        return 2 / PI / (i+1) * pow(-1, i);
      }

      double (*coeff_func_from_symbol(VALUE waveform_symbol)) (unsigned long) {
        ID waveform_id = SYM2ID(waveform_symbol);
        if (waveform_id == rb_intern("sine"))
          return coeff_sine_wave;
        else if (waveform_id == rb_intern("triangle"))
          return coeff_triangle_wave;
        else if (waveform_id == rb_intern("square"))
          return coeff_square_wave;
        else if (waveform_id == rb_intern("sawtooth"))
          return coeff_sawtooth_wave;
        else
          rb_raise(rb_eKeyError, "Symbol does not match a recognized waveform");
      }
    EOC

    builder.c_singleton <<-EOC
      VALUE new(double fundamental) {
        FourierSeries *fs = malloc(sizeof(FourierSeries));
        fs->odd_coeff_count = DEFAULT_COEFF_COUNT;
        fs->even_coeff_count = DEFAULT_COEFF_COUNT;
        fs->odd_coefficients = malloc(fs->odd_coeff_count * sizeof(double));
        fs->even_coefficients = malloc(fs->even_coeff_count * sizeof(double));

        fs->fundamental = fundamental;
        fs->odd_coefficients[0] = 1;
        fs->even_coefficients[0] = 0;
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
        VALUE odd_coeff_list = array_to_list(fs->odd_coefficients, fs->odd_coeff_count);
        VALUE even_coeff_list = array_to_list(fs->even_coefficients, fs->even_coeff_count);
        return rb_ary_new3(2, odd_coeff_list, even_coeff_list);
      }
    EOC

    builder.c <<-EOC
      void coefficients_equals(VALUE coeff_list) {
        FourierSeries *fs = get_fourier_series(self);

        VALUE odd_coeff_list = rb_ary_entry(coeff_list, 0);
        VALUE even_coeff_list = rb_ary_entry(coeff_list, 1);

        list_to_array(odd_coeff_list, &fs->odd_coefficients, &fs->odd_coeff_count);
        list_to_array(even_coeff_list, &fs->even_coefficients, &fs->even_coeff_count);
      }
    EOC

    builder.c <<-EOC
      double sample(double time_step) {
        FourierSeries *fs = get_fourier_series(self);
        fs->phase += time_step * fs->fundamental;
        double sum = 0;

        unsigned long i;
        for (i = 0; i < fs->odd_coeff_count && is_harmonic_played(i, fs); i++)
          sum += fs->odd_coefficients[i] * sin(2*PI * (i+1) * fs->phase);
        for (i = 0; i < fs->even_coeff_count && is_harmonic_played(i, fs); i++)
          sum += fs->even_coefficients[i] * cos(2*PI * (i+1) * fs->phase);
        return sum;
      }
    EOC

    builder.c <<-EOC
      void set_to(VALUE waveform_symbol, unsigned long precision) {
        double (* coeff_func) (unsigned long);
        coeff_func = coeff_func_from_symbol(waveform_symbol);

        FourierSeries *fs = get_fourier_series(self);
        
        realloc_if_needed(&fs->odd_coefficients, &fs->odd_coeff_count, precision);

        unsigned long i;
        for (i = 0; i < fs->odd_coeff_count; i++) {
          if (i > precision)
            fs->odd_coefficients[i] = 0;
          else
            fs->odd_coefficients[i] = coeff_func(i);
        }
        for (i = 0; i < fs->even_coeff_count; i++)
          fs->even_coefficients[i] = 0;
      }
    EOC
  end
end