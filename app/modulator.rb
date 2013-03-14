require 'inline'
require_relative './oscillator'

class Modulator < Oscillator
  attr_reader :amount, :modulated

  def initialize(sampleable, *args)
    super(*args)
    @amount = 0
    @modulated = sampleable
  end

  def amount=(new_amount)
    if new_amount > 1
      @amount = 1
    elsif new_amount < 0
      @amount = 0
    else
      @amount = new_amount
    end
  end

  inline do |builder|
    builder.c <<-EOC
      double sample(double time_step) {
        VALUE rb_time_step = rb_float_new(time_step);

        double amount = NUM2DBL( rb_funcall(self, rb_intern("amount"), 0) );

        VALUE modulated = rb_funcall(self, rb_intern("modulated"), 0);
        double modulated_sample = NUM2DBL( rb_funcall(modulated, rb_intern("sample"), 1, rb_time_step) );

        double super_sample = NUM2DBL( rb_call_super(1, &rb_time_step) );

        return modulated_sample * (1 - amount*super_sample);
      }
    EOC
  end
end