require_relative 'app/novitiate'  

n = Novitiate.new

puts 'Starting Novitiate...'
n.turn_on

puts 'Playing oscillator (632 Hz square)...'
n.gain = 0.5
n.osc_wave_setting = :square
n.play_oscillator(2)

puts 'Adding LFO (3 Hz sawtooth)...'
n.mod_amount = 1
n.mod_wave_setting = :sawtooth
n.play_modulator(2)

puts 'Adding LPF (level = 0.3, resonance = 0)...'
n.filter_level = 0.3
n.play_filter(2)

(1..10).each do |i|
  n.filter_resonance = i * 0.1
  puts "(resonance = #{n.filter_resonance})..."
  n.play_filter(1)
end

puts 'Stopping Novitiate'
n.turn_off
