require 'spec_helper'
require_relative '../app/novitiate'
require_relative '../app/oscillator'
require_relative '../app/speaker'

describe "Novitiate" do
  let(:speaker) { Speaker.new(output: :mute) }
  let(:nov) { Novitiate.new(speaker) }
  subject { nov }

  describe "initialize" do
    it "should have a loud speaker by default" do
      PortAudio::C.should_receive(:write_stream)
      loud_nov = Novitiate.new
      loud_nov.turn_on
      loud_nov.fire_envelope
      loud_nov.turn_off
    end
  end

  describe "turn_on" do
    it "should turn on its speaker" do
      speaker.should_receive(:turn_on)
      nov.turn_on
    end
  end

  describe "turn_off" do
    before { nov.turn_on }
    it "should turn off its speaker" do
      speaker.should_receive(:turn_off).and_call_original
      nov.turn_off
    end
  end

  describe "fire_envelope" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should call play on speaker" do
      speaker.should_receive(:play)
      nov.fire_envelope
    end
  end

  describe "play_oscillator" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should call play on speaker" do
      oscillator = double(sample: 0)
      subject.stub(oscillator: oscillator)
      speaker.should_receive(:play).with(1, oscillator)
      nov.play_oscillator(1)
    end

    describe "sampling the waveform" do
      let(:freq) { nov.osc_frequency }

      it "samples a sine wave" do
        nov.play_oscillator(1e-5)
        speaker.buffer.each do |f,c,s|
          s.should be_within(1e-6).of(Math.sin(Math::PI * 2 * (freq*(f+1)/44100.0).modulo(1)))
        end
      end

      it "samples a square wave" do
        nov.osc_wave_setting = :square
        nov.play_oscillator(1e-5)
        speaker.buffer.each do |f,c,s|
          if (freq*(f+1)/44100.0).modulo(1) < 0.5
            s.should be_within(1e-6).of(-1)
          else
            s.should be_within(1e-6).of(1)
          end
        end
      end
    end
  end

  describe "play_modulator" do
    let(:freq) { nov.mod_frequency }

    before do
      nov.turn_on
      nov.osc_wave_setting = :square
      nov.osc_frequency_setting = 1
    end

    after { nov.turn_off }

    it "should call play on speaker" do
      modulator = double(sample: 0)
      subject.stub(modulator: modulator)
      speaker.should_receive(:play).with(1e-5, modulator)
      nov.play_modulator(1e-5)
    end
  end

  describe "play_filter" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should call play on speaker" do
      filter = double(sample: 0)
      subject.stub(filter: filter)
      speaker.should_receive(:play).with(1e-5, filter)
      nov.play_filter(1e-5)
    end
  end

  describe "gain" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should delegate gain setter to speaker" do
      speaker.should_receive(:gain=).with(0.5)
      nov.gain = 0.5
    end

    it "should delegate gain getter to speaker" do
      speaker.should_receive(:gain)
      nov.gain
    end
  end

  describe "osc_wave_setting" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should have a sine wave setting by default" do
      nov.osc_wave_setting.should == :sine
    end

    it "can be set to square" do
      nov.osc_wave_setting = :square
      nov.osc_wave_setting.should == :square
    end

    it "can be set to triangle" do
      nov.osc_wave_setting = :triangle
      nov.osc_wave_setting.should == :triangle
    end

    it "can be set to sawtooth" do
      nov.osc_wave_setting = :sawtooth
      nov.osc_wave_setting.should == :sawtooth
    end

    it "cannot be set to anything else" do
      nov.osc_wave_setting = :sawtooth
      nov.osc_wave_setting = :invalid
      nov.osc_wave_setting.should == :sawtooth
    end
  end

  describe "osc_frequency_setting" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "can be set" do
      nov.osc_frequency_setting = 0.5
      nov.osc_frequency_setting.should be_within(1e-6).of(0.5)
    end

    it "can be set as high as one" do
      nov.osc_frequency_setting = 1.1
      nov.osc_frequency_setting.should be_within(1e-6).of(1)
    end

    it "can be set as low as zero" do
      nov.osc_frequency_setting = -0.1
      nov.osc_frequency_setting.should be_within(1e-6).of(0)
    end

    specify "0 corresponds to 20 Hz" do
      nov.osc_frequency_setting = 0
      nov.osc_frequency.should be_within(1e-6).of(20)
    end

    specify "1 corresponds to 20_000 Hz" do
      nov.osc_frequency_setting = 1
      nov.osc_frequency.should be_within(1e-6).of(2e4)
    end
  end

  describe "mod_wave_setting" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "should have a sine wave setting by default" do
      nov.mod_wave_setting.should == :sine
    end

    it "can be set to square" do
      nov.mod_wave_setting = :square
      nov.mod_wave_setting.should == :square
    end

    it "can be set to triangle" do
      nov.mod_wave_setting = :triangle
      nov.mod_wave_setting.should == :triangle
    end

    it "can be set to sawtooth" do
      nov.mod_wave_setting = :sawtooth
      nov.mod_wave_setting.should == :sawtooth
    end

    it "cannot be set to anything else" do
      nov.mod_wave_setting = :sawtooth
      nov.mod_wave_setting = :invalid
      nov.mod_wave_setting.should == :sawtooth
    end
  end

  describe "mod_frequency_setting" do
    before { nov.turn_on }
    after { nov.turn_off }

    it "can be set" do
      nov.mod_frequency_setting = 0.5
      nov.mod_frequency_setting.should be_within(1e-6).of(0.5)
    end

    it "can be set as high as one" do
      nov.mod_frequency_setting = 1.1
      nov.mod_frequency_setting.should be_within(1e-6).of(1)
    end

    it "can be set as low as zero" do
      nov.mod_frequency_setting = -0.1
      nov.mod_frequency_setting.should be_within(1e-6).of(0)
    end

    specify "0 corresponds to 0.1 Hz" do
      nov.mod_frequency_setting = 0
      nov.mod_frequency.should be_within(1e-6).of(0.1)
    end

    specify "1 corresponds to 100 Hz" do
      nov.mod_frequency_setting = 1
      nov.mod_frequency.should be_within(1e-6).of(100)
    end
  end

  describe "mod_amount" do
    before { nov.turn_on }
    after { nov.turn_off }

    its(:mod_amount) { should == 0 }

    it "can be set as high as 1" do
      nov.mod_amount = 1.1
      nov.mod_amount.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      nov.mod_amount = -0.1
      nov.mod_amount.should be_within(1e-6).of(0)
    end
  end

  describe "filter_level" do
    before { nov.turn_on }
    after { nov.turn_off }

    its(:filter_level) { should == 0 }    

    it "can be set as high as 1" do
      nov.filter_level = 1.1
      nov.filter_level.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      nov.filter_level = -0.1
      nov.filter_level.should be_within(1e-6).of(0)
    end
  end

  describe "filter_resonance" do
    before { nov.turn_on }
    after { nov.turn_off }

    its(:filter_resonance) { should == 0 }    

    it "can be set as high as 1" do
      nov.filter_resonance = 1.1
      nov.filter_resonance.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      nov.filter_resonance = -0.1
      nov.filter_resonance.should be_within(1e-6).of(0)
    end
  end
end