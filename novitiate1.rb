require '/home/nhollon/ruby_projects/novitiate/app/novitiate'

WAVEFORM_STRINGS = { sine: "Sine", triangle: "Triangle", square: "Square", sawtooth: "Sawtooth" }

Shoes.app width: 1000, height: 500, resizable: false do
  nov = Novitiate.new
  elements = {}
  
  draw_app elements
  set_defaults elements, nov

  elements[:fire_button].click do
    play_sound elements, nov
  end
end

def play_sound(elements, nov)
  nov.osc_wave_setting = WAVEFORM_STRINGS.key elements[:osc_wave_listbox].text
  nov.mod_wave_setting = WAVEFORM_STRINGS.key elements[:mod_wave_listbox].text
  nov.attack = elements[:attack_field].text.to_f
  nov.decay = elements[:decay_field].text.to_f
  nov.hold = elements[:hold_field].text.to_f
  nov.release = elements[:release_field].text.to_f
  nov.osc_frequency_setting = elements[:osc_freq_slider].fraction
  nov.mod_amount = elements[:mod_amt_slider].fraction
  nov.mod_frequency_setting = elements[:mod_freq_slider].fraction
  nov.filter_level = elements[:filter_slider].fraction
  nov.sustain = elements[:sustain_slider].fraction
  nov.gain = elements[:gain_slider].fraction

  nov.fire_envelope
end

def set_defaults(elements, nov)
  elements[:osc_wave_listbox].choose WAVEFORM_STRINGS[nov.osc_wave_setting]
  elements[:mod_wave_listbox].choose WAVEFORM_STRINGS[nov.mod_wave_setting]
  elements[:attack_field].text = nov.attack
  elements[:decay_field].text = nov.decay
  elements[:hold_field].text = nov.hold
  elements[:release_field].text = nov.release
end

def draw_app(elements)
  stack width: 0.8, height: 1.0 do
    oscillator_flow elements
    modulator_flow elements
    filter_flow elements
    envelope_flow elements
  end

  stack width: 0.2, height: 1.0 do
    fire_stack elements
  end
end

def oscillator_flow(elements)
  flow height: 0.2 do
    draw_border
    draw_title_panel "Oscillator"
    spacer 0.25
    elements[:osc_wave_listbox] = draw_wave_listbox 0.20
    elements[:osc_freq_slider] = draw_slider "Frequency", 0.28
  end
end

def modulator_flow(elements)
  flow height: 0.2 do
    draw_border
    draw_title_panel "Modulator"
    elements[:mod_amt_slider] = draw_slider "Amount", 0.25
    elements[:mod_wave_listbox] = draw_wave_listbox 0.20
    elements[:mod_freq_slider] = draw_slider "Frequency", 0.25
  end
end

def filter_flow(elements)
  flow height: 0.2 do
    draw_border
    draw_title_panel "Filter"
    spacer 0.25
    elements[:filter_slider] = draw_slider "Level", 0.25
  end
end

def envelope_flow(elements)
  flow height: 0.4 do
    draw_border
    draw_title_panel "Envelope"

    stack width: 0.75, height: 1.0 do
      flow height: 0.5 do
        elements[:attack_field] = draw_number_field "Attack", 0.25
        elements[:decay_field] = draw_number_field "Decay", 0.25
        elements[:hold_field] = draw_number_field "Hold", 0.25
        elements[:release_field] = draw_number_field "Release", 0.25
      end

      flow height: 0.5 do
        spacer 0.33
        elements[:sustain_slider] = draw_slider "Sustain", 0.33
      end
    end
  end
end

def fire_stack(elements)
  elements[:fire_button] = button "FIRE", width: 1.0, height: 0.5, margin: [50, 100, 50, 100]
  flow do
    spacer 0.25
    elements[:gain_slider] = draw_slider "Gain", 0.5
  end
end

def draw_border
  border lightseagreen, strokewidth: 5
end

def draw_title_panel(title)
  stack width: 0.25, height: 1.0 do
    background lightseagreen
    caption title, align: "right", margin: 10
  end
end

def draw_wave_listbox(width)
  stack width: width do
    list_box items: WAVEFORM_STRINGS.values, width: 1.0, margin: [0.2,30,0.2,0]
  end.contents.first
end

def draw_slider(title, width)
  stack width: width do
    slider width: 1.0, margin: [0,25,0,0]
    inscription title, align: "center"
  end.contents.first
end

def draw_number_field(title, width)
  stack width: width, height: 1.0 do
    edit_line width: 1.0, margin: [0.35,40,0.35,0]
    inscription title, align: "center"
  end.contents.first
end

def spacer(width)
  stack width: width
end