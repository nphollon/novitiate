require_relative 'app/novitiate'  

n = Novitiate.new(Speaker.new(sample_doubling = true))

puts 'Starting Novitiate...'
n.turn_on

puts 'Playing oscillator (632 Hz square)...'
n.gain = 0.5
n.osc_wave_setting = :square
n.play_oscillator(5)

puts 'Playing oscillator with LFO (3 Hz sawtooth)...'
n.mod_amount = 1
n.mod_wave_setting = :sawtooth
n.play_modulator(5)

puts 'Playing oscillator with LPF (level = 0.3, resonance = 0)...'
n.filter_amount = 0.3
n.mod_amount = 0
n.play_filter(5)

puts 'Stopping Novitiate'
n.turn_off
