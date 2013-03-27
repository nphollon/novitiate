require 'spec_helper'
require_relative '../../app/novitiate'
require_relative '../../app/speaker'

describe Novitiate do
  let(:speaker) { Speaker.new(output: :mute) }
  let(:novitiate) { Novitiate.new(speaker) }
  subject { novitiate }

  its(:gain) { should be_within(1e-6).of(1) }
  its(:osc_wave_setting) { should == :sine }
  its(:osc_frequency_setting) { should be_within(1e-6).of(0.5) }
  its(:osc_frequency) { should be_within(1e-6).of(2*10**2.5) }
  its(:mod_wave_setting) { should == :sine }
  its(:mod_frequency_setting) { should be_within(1e-6).of(0.5) }
  its(:mod_frequency) { should be_within(1e-6).of(10**0.5) }
  its(:mod_amount) { should be_within(1e-6).of(0) }

  describe "Audio output" do
    subject { Novitiate.new }
    let(:loudspeaker) { subject.send :renderer }

    it "should play sound when envelope is fired" do
      loudspeaker.stream.should_receive(:write).at_least(1).times
      subject.fire_envelope
    end

    it "should play sound when oscillator plays" do
      loudspeaker.stream.should_receive(:write).at_least(1).times
      subject.play_oscillator(1)
    end
  end

  describe "Gain control" do
    it "should not go higher than 1.0" do
      novitiate.gain = 1.1
      novitiate.gain.should be_within(1e-6).of(1)
    end

    it "should not go lower than 0.0" do
      novitiate.gain = -0.1
      novitiate.gain.should be_within(1e-6).of(0)
    end

    it "should be silent when muted" do
      novitiate.gain = 0
      novitiate.play_oscillator(1e-5)
      speaker.buffer.each do |s|
        s.should be_within(1e-6).of(0)
      end
    end

    it "should be loud when at maximum gain" do
      novitiate.gain = 1
      novitiate.osc_wave_setting = :square
      novitiate.play_oscillator(1e-5)
      speaker.buffer.each do |s|
        s.abs.should be_within(1e-6).of(1)
      end
    end
  end

  describe "Oscillation frequency control" do
    it "should go as high as 20_000 Hz" do
      novitiate.osc_frequency_setting = 1.1
      novitiate.osc_frequency_setting.should be_within(1e-6).of(1)
      novitiate.osc_frequency.should be_within(1).of(2e4)
    end

    it "should go as low as 20 Hz" do
      novitiate.osc_frequency_setting = -0.1
      novitiate.osc_frequency_setting.should be_within(1e-6).of(0)
      novitiate.osc_frequency.should be_within(1e-6).of(20)
    end
  end

  describe "Modulations controls" do
    it "should go as high as 100 Hz" do
      novitiate.mod_frequency_setting = 1.1
      novitiate.mod_frequency_setting.should be_within(1e-6).of(1)
      novitiate.mod_frequency.should be_within(1e-6).of(100)
    end

    it "should go as low as 0.1 Hz" do
      novitiate.mod_frequency_setting = -0.1
      novitiate.mod_frequency_setting.should be_within(1e-6).of(0)
      novitiate.mod_frequency.should be_within(1e-6).of(0.1)
    end

    it "should have a smooth square wave" do
      speaker.should_receive(:play).at_least(1).times.and_call_original
      novitiate.mod_wave_setting = :square
      novitiate.mod_frequency_setting = 1
      novitiate.play_modulator(1e-5)
      buffer = speaker.buffer
      (1...buffer.length).each do |i|
        buffer[i].should be_within(0.1).of(buffer[i-1])
      end
    end

    it "should have a smooth sawtooth wave" do
      speaker.should_receive(:play).at_least(1).times.and_call_original
      novitiate.mod_wave_setting = :sawtooth
      novitiate.mod_frequency_setting = 1
      novitiate.play_modulator(1e-5)
      buffer = speaker.buffer
      (1...buffer.length).each do |i|
        buffer[i].should be_within(0.1).of(buffer[i-1])
      end
    end

    specify "amount should go as high as 1" do
      novitiate.mod_amount = 2
      novitiate.mod_amount.should be_within(1e-6).of(1)
    end

    specify "amount should go as low as 0" do
      novitiate.mod_amount = -2
      novitiate.mod_amount.should be_within(1e-6).of(0)
    end

    it "should mix modulation with oscillation based on mod_amount" do
      novitiate.osc_frequency_setting = 0
      novitiate.mod_frequency_setting = 0
      novitiate.mod_amount = 0.5
      novitiate.play_modulator(1e-5)
      i = 0
      speaker.buffer.each do |s|
        i += 1
        expected = Math.sin(i * 40*Math::PI/44100.0) *
          (0.5 + 0.5*Math.sin(i * 0.2*Math::PI/44100.0))
        s.should be_within(1e-6).of(expected)
      end
    end
  end

  describe "Filter settings" do
    describe "with no resonance" do

      before { novitiate.filter_resonance = 0 }

      it "should be silent if filter_level is 0" do
        novitiate.filter_level = 0
        novitiate.play_filter(1e-5)
        speaker.buffer.each do |s|
          s.should be_within(1e-6).of(0)
        end
      end

      it "should be neutral if filter amount is 1" do
        novitiate.filter_level = 1
        novitiate.osc_wave_setting = :square
        novitiate.play_filter(1e-5)
        speaker.buffer.each do |s|
          s.abs.should be_within(1e-6).of(1)
        end
      end
    end
  end

  describe "Envelope" do
    it "should affect the amplitude of the output" do
      stage_duration = 256 * 0.25 / 44100
      novitiate.osc_wave_setting = :square
      novitiate.filter_level = 1.0
      novitiate.attack = stage_duration
      novitiate.decay = stage_duration
      novitiate.hold = stage_duration
      novitiate.release = stage_duration
      novitiate.sustain = 0.5

      novitiate.fire_envelope

      buffer = speaker.buffer
      (0...64).each do |i|
        buffer[    i].abs.should be_within(1e-6).of(      (i+1)/64.0)
        buffer[ 64+i].abs.should be_within(1e-6).of(1.0 - (i+1)/128.0)
        buffer[128+i].abs.should be_within(1e-6).of(0.5)
        buffer[192+i].abs.should be_within(1e-6).of(0.5 - (i+1)/128.0)
      end
    end
  end
end