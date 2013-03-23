require 'inline'

class Filter
  inline do |builder|
    builder.include '"math.h"'

    builder.prefix <<-EOC
      typedef struct Filter {
        VALUE filtered;
        double level;
        int cache_size;
        double *cache;
        double resonance;
      } Filter;

      void free_filter(Filter *filter) {
        free(filter->cache);
        free(filter);
      }

      double even_cache_coeff(int limit, double b) {
        int i;
        double coeff = 0;

        for (i = 0; i <= limit; i++)
          coeff += pow(b, i) * (2*i + 1);
        
        coeff *= (1 - b);
        coeff += -1 - 2*b/(1-b);

        return coeff;
      }

      double odd_cache_coeff(int limit, double b) {
        int i;
        double coeff = 0;

        for (i = 0; i <= limit; i++)
          coeff += pow(b, i) * (2*i + 1);
        
        coeff += -pow(b, limit);
        coeff *= -(1 - b);
        coeff += 1 + 2*b/(1-b);

        return coeff;
      }

      double cache_coeff(int index, double b) {
        if (index % 2 == 0)
          return even_cache_coeff(index/2 - 1, b);
        else
          return odd_cache_coeff((index-1)/2, b);
      }

      double weighted_cache_sum(Filter *filter) {
        int i;
        double sum = 0;

        for (i = 0; i < filter->cache_size; i++)
          sum += filter->cache[i] * cache_coeff(i+1, -filter->resonance);

        return sum;
      }
    EOC

    builder.c_singleton <<-EOC
      VALUE new(VALUE sampleable, int cache_size) {
        int i;
        Filter *filter;
        filter = malloc(sizeof(Filter));
        
        filter->filtered = sampleable;
        filter->level = 0;
        filter->resonance = 0;


        filter->cache_size = cache_size;
        filter->cache = malloc(cache_size * sizeof(double));
        for (i = 0; i < cache_size; i++)
          filter->cache[i] = 0;

        return Data_Wrap_Struct(self, 0, free_filter, filter);
      }
    EOC

    builder.struct_name = "Filter"
    builder.reader :cache_size, "int"
    builder.reader :level, "double"
    builder.reader :resonance, "double"

    builder.c <<-EOC
      void level_equals(double new_level) {
        Filter *filter;
        Data_Get_Struct(self, Filter, filter);

        if (new_level > 1)
          filter->level = 1;
        else if (new_level < 0)
          filter->level = 0;
        else
          filter->level = new_level;
      }
    EOC

    builder.c <<-EOC
      void resonance_equals(double new_resonance) {
        Filter *filter;
        Data_Get_Struct(self, Filter, filter);

        if (new_resonance > 1)
          filter->resonance = 1;
        else if (new_resonance < 0)
          filter->resonance = 0;
        else
          filter->resonance = new_resonance;
      }
    EOC

    builder.c <<-EOC
      VALUE cache() {
        Filter *filter;
        Data_Get_Struct(self, Filter, filter);

        VALUE *value_cache;
        value_cache = malloc(filter->cache_size * sizeof(double));

        int i;
        for (i = 0; i < filter->cache_size; i++)
          value_cache[i] = rb_float_new(filter->cache[i]);

        VALUE rb_cache = rb_ary_new4(filter->cache_size, value_cache);
        free(value_cache);
        return rb_cache;
      }
    EOC

    builder.c <<-EOC
      double sample(double time_step) {
        Filter *filter;
        Data_Get_Struct(self, Filter, filter);

        double unfiltered_sample = NUM2DBL( rb_funcall(filter->filtered,
                                                      rb_intern("sample"),
                                                      1,
                                                      rb_float_new(time_step)) );
        double filtered_sample = filter->level * unfiltered_sample
                                + (1-filter->level) * weighted_cache_sum(filter);
        rb_funcall(self, rb_intern("update_cache"), 1, rb_float_new(filtered_sample));
        return filtered_sample;
      }
    EOC

    builder.c <<-EOC
      void update_cache(double new_value) {
        int i;
        Filter *filter;
        Data_Get_Struct(self, Filter, filter);        

        for (i = filter->cache_size-1; i > 0; i--)
          filter->cache[i] = filter->cache[i-1];

        if (new_value > 1)
          filter->cache[0] = 1;
        else if (new_value < -1)
          filter->cache[0] = -1;
        else
          filter->cache[0] = new_value;
      }
    EOC
  end
end