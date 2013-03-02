require 'spec_helper'
require_relative '../oscillator'

describe Oscillator do
  subject { Oscillator.new(10, 100, 0.5) }

  its (:wave_setting) { should == :sine }
  its (:frequency_setting) { should == 0.5 }
  its (:min_frequency) { should == 10 }
  its (:max_frequency) { should == 100 }
  it "should have a sine waveform by default" do
    subject.waveform.class == Oscillator::SineWave
  end

  describe "wave_settings" do
    specify "triangle wave setting" do
      subject.wave_setting = :triangle
      subject.waveform.class.should == Oscillator::TriangleWave
    end

    specify "square wave setting" do
      subject.wave_setting = :square
      subject.waveform.class.should == Oscillator::SquareWave
    end

    specify "sawtooth wave setting" do
      subject.wave_setting = :sawtooth
      subject.waveform.class.should == Oscillator::SawtoothWave
    end
  end

  describe "frequency settings" do
    before do
      @freq1 = subject.frequency
      subject.frequency_setting = 0.6
    end

    its(:frequency) { should be > @freq1 }
    its(:frequency) { should == subject.waveform.frequency }

    specify "min frequency corresponds to freq setting 0" do
      subject.frequency_setting = 0.0
      subject.frequency.should be_within(1e-3).of(10)
    end

    specify "max frequency corresponds to freq setting 1" do
      subject.frequency_setting = 1.0
      subject.frequency.should be_within(1e-3).of(100)
    end

    specify "logarithmically-scaled frequency" do
      freq2 = subject.frequency
      subject.frequency_setting = 0.7
      (subject.frequency / freq2).should be_within(1e-3).of(freq2 / @freq1)
    end

    it "can't have a frequency setting higher than 1" do
      expect { subject.frequency_setting = 1.001 }.to raise_error(RangeError)
    end

    it "can't have a frequency setting lower than 0" do
      expect { subject.frequency_setting = -0.001 }.to raise_error(RangeError)
    end

    it "can set frequency directly" do
      subject.frequency = @freq1
      subject.frequency_setting.should == 0.5
    end
  end
end