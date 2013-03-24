require 'inline'

class Envelope
  attr_reader :enveloped, :time
  attr_writer :time
  private :enveloped, :time, :time=

  def initialize(sampleable)
    @enveloped = sampleable
    @time = 0
  end

  inline do |builder|
    builder.c <<-EOC
      double sample(double time_step) {
        VALUE enveloped = rb_funcall(self, rb_intern("enveloped"), 0);
        double osc_sample = NUM2DBL( rb_funcall(enveloped, rb_intern("sample"), 1, rb_float_new(time_step)) );
        double attack = NUM2DBL( rb_funcall(self, rb_intern("attack"), 0) );
        double decay = NUM2DBL( rb_funcall(self, rb_intern("decay"), 0) ); 
        double hold = NUM2DBL( rb_funcall(self, rb_intern("hold"), 0) );
        double sustain = NUM2DBL( rb_funcall(self, rb_intern("sustain"), 0) );
        double release = NUM2DBL( rb_funcall(self, rb_intern("release"), 0) );

        double amplitude;

        double time = NUM2DBL( rb_funcall(self, rb_intern("time"), 0) );  
        time += time_step;
        rb_funcall(self, rb_intern("time="), 1, rb_float_new(time));

        if (time < attack) {
          amplitude = time/attack;
        } else if (time < attack + decay)
          amplitude = 1 - (1-sustain)/decay * (time-attack);
        else if (time < attack + decay + hold)
          amplitude = sustain;
        else if (time < attack + decay + hold + release)
          amplitude = sustain - sustain/release * (time-attack-decay-hold);
        else
          return 0;

        return amplitude * osc_sample;
      }
    EOC
  end

  def fire(renderer)
    self.time = 0
    renderer.play(duration, self)
  end

  def duration
    attack + decay + hold + release
  end

  def attack
    @attack || 0
  end

  def attack=(new_attack)
    @attack = (new_attack < 0) ? 0 : new_attack
  end

  def decay
    @decay || 0
  end

  def decay=(new_decay)
    @decay = (new_decay < 0) ? 0 : new_decay
  end

  def hold
    @hold || 1
  end

  def hold=(new_hold)
    @hold = (new_hold < 0) ? 0 : new_hold
  end

  def release
    @release || 0
  end

  def release=(new_release)
    @release = (new_release < 0) ? 0 : new_release
  end

  def sustain
    @sustain || 1
  end

  def sustain=(new_sustain)
    if new_sustain > 1
      @sustain = 1
    elsif new_sustain < 0
      @sustain = 0
    else
      @sustain = new_sustain
    end
  end
end