require 'inline'

class Envelope
  inline do |builder|
    builder.prefix <<-EOC
      typedef struct Envelope {
        VALUE enveloped;
        double attack;
        double decay;
        double hold;
        double sustain;
        double release;
        double time;
      } Envelope;

      Envelope * get_envelope(VALUE self) {
        Envelope *env;
        Data_Get_Struct(self, Envelope, env);
        return env;
      }

      void mark_envelope(Envelope *env) {
        rb_gc_mark(env->enveloped);
      }

      void free_envelope(Envelope *env) {
        free(env);
      }
    EOC

    builder.c_singleton <<-EOC
      VALUE new(VALUE enveloped) {
        Envelope *env;

        env = malloc(sizeof(Envelope));
        env->enveloped = enveloped;
        env->attack = 0;
        env->decay = 0;
        env->hold = 1;
        env->sustain = 1;
        env->release = 0;
        env->time = 0;

        return Data_Wrap_Struct(self, mark_envelope, free_envelope, env);
      }
    EOC

    builder.struct_name = "Envelope"
    builder.reader :attack, 'double'
    builder.reader :decay, 'double'
    builder.reader :hold, 'double'
    builder.reader :sustain, 'double'
    builder.reader :release, 'double'

    builder.c <<-EOC
      void attack_equals(double attack) {
        Envelope *env = get_envelope(self);
        if (attack < 0)
          env->attack = 0;
        else
          env->attack = attack;
      }
    EOC

    builder.c <<-EOC
      void decay_equals(double decay) {
        Envelope *env = get_envelope(self);
        if (decay < 0)
          env->decay = 0;
        else
          env->decay = decay;
      }
    EOC

    builder.c <<-EOC
      void hold_equals(double hold) {
        Envelope *env = get_envelope(self);
        if (hold < 0)
          env->hold = 0;
        else
          env->hold = hold;
      }
    EOC

    builder.c <<-EOC
      void release_equals(double release) {
        Envelope *env = get_envelope(self);
        if (release < 0)
          env->release = 0;
        else
          env->release = release;
      }
    EOC

    builder.c <<-EOC
      void sustain_equals(double sustain) {
        Envelope *env = get_envelope(self);
        if (sustain < 0)
          env->sustain = 0;
        else if (sustain > 1)
          env->sustain = 1;
        else
          env->sustain = sustain;
      }
    EOC

    builder.c <<-EOC
      double duration() {
        Envelope *env = get_envelope(self);
        return env->attack + env->decay + env->hold + env->release;
      }
    EOC

    builder.c <<-EOC
      double sample(double time_step) {
        Envelope *env = get_envelope(self);
        double osc_sample, amplitude;

        env->time += time_step;
        
        if (env->time < env->attack) {
          amplitude = env->time/env->attack;
        } else if (env->time < env->attack + env->decay)
          amplitude = 1 - (1-env->sustain)/env->decay * (env->time-env->attack);
        else if (env->time < env->attack + env->decay + env->hold)
          amplitude = env->sustain;
        else if (env->time < env->attack + env->decay + env->hold + env->release)
          amplitude = env->sustain - env->sustain/env->release * (env->time-env->attack-env->decay-env->hold);
        else
          return 0;

        osc_sample = NUM2DBL( rb_funcall(env->enveloped, rb_intern("sample"), 1, rb_float_new(time_step)) );
        return amplitude * osc_sample;
      }
    EOC

    builder.c <<-EOC
      void fire(VALUE renderer) {
        Envelope *env = get_envelope(self);
        double duration = env->attack + env->decay + env->hold + env->release;
        env->time = 0;
        rb_funcall(renderer, rb_intern("play"), 2, rb_float_new(duration), self);
      }
    EOC
  end
end