require_relative 'app/novitiate'

n = Novitiate.new

puts 'Starting Novitiate...'
n.turn_on

puts 'Playing oscillator (632 Hz square)...'
n.gain = 0.5
n.osc_wave_setting = :square
n.play_oscillator(2)

puts 'Playing oscillator with LFO (3 Hz sawtooth)...'
n.mod_amount = 1
n.mod_wave_setting = :sawtooth
n.play_modulator(2)

puts 'Stopping Novitiate'
n.turn_off