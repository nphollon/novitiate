require 'novitiate'

n = Novitiate.new
n.turn_on
n.play do |t|
  case t
  when (0..1)
    n.wave_setting = :sine
    n.frequency_setting += 0.0005
  when (1..2)
    n.wave_setting = :square
    n.frequency_setting -= 0.001
  when (2..3)
    n.wave_setting = :triangle
    n.frequency_setting += 0.002
  when (3..4)
    n.wave_setting = :sawtooth
    n.frequency_setting -= 0.004
  else
    break
  end
end
n.turn_off