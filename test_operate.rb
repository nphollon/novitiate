require 'novitiate'

n = Novitiate.new
n.turn_on
n.wave_setting = :triangle
n.frequency = 600.0
n.play do |t|
  case t
  when (0.75..1.0)
    n.slew_frequency(7.0/3)
  when (1.75..2.0)
    n.slew_frequency (5.0/3)
  else
    break if t > 3
  end
end
n.turn_off