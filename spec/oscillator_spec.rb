require 'spec_helper'
require_relative '../app/oscillator'

describe Oscillator do
  subject { Oscillator.new(10, 100, 0.5) }

  its (:frequency_setting) { should == 0.5 }
  its (:min_frequency) { should == 10 }
  its (:max_frequency) { should == 100 }

  describe "wave_setting" do
    its (:wave_setting) { should == :sine }
    its (:waveform) { should be_kind_of(Oscillator::SineWave) }
      
    it "can be a square" do
      subject.wave_setting = :square
      subject.waveform.should be_kind_of(Oscillator::SquareWave)
    end

    it "can be a triangle" do
      subject.wave_setting = :triangle
      subject.waveform.should be_kind_of(Oscillator::TriangleWave)
    end

    it "can be a sawtooth" do
      subject.wave_setting = :sawtooth
      subject.waveform.should be_kind_of(Oscillator::SawtoothWave)
    end

    it "cannot be anything else" do
      subject.wave_setting = :invalid
      subject.waveform.should be_kind_of(Oscillator::SineWave)
    end
  end

  describe "sample" do
    it "should call value_at on waveform" do
      subject.waveform.should_receive(:value_at).with(5)
      subject.sample(5)
    end

    describe "accumulating time steps" do
      before { subject.sample(5) }

      it "should add sample parameter to running total" do
        subject.waveform.should_receive(:value_at).with(10)
        subject.sample(5)
      end
    end
  end

  describe "frequency_setting" do
    it "has a settable frequency" do
      subject.frequency_setting = 0.1
      subject.frequency_setting.should be_within(1e-6).of(0.1)
    end

    it "maxes out at 1" do
      subject.frequency_setting = 2
      subject.frequency_setting.should be_within(1e-6).of(1)      
    end

    it "mins out at 0" do
      subject.frequency_setting = -5
      subject.frequency_setting.should be_within(1e-6).of(0)
    end
  end

  describe "frequency" do
    its(:frequency) { should == subject.waveform.frequency }

    specify "min frequency corresponds to freq setting 0" do
      subject.frequency_setting = 0.0
      subject.frequency.should be_within(1e-3).of(10)
    end

    specify "max frequency corresponds to freq setting 1" do
      subject.frequency_setting = 1.0
      subject.frequency.should be_within(1e-3).of(100)
    end

    it "maxes out at freq setting 1" do
      subject.frequency_setting = 2.0
      subject.frequency.should be_within(1e-3).of(100)
    end

    it "mins out at freq setting 0" do
      subject.frequency_setting = -10
      subject.frequency.should be_within(1e-3).of(10)
    end

    specify "logarithmically-scaled frequency" do
      subject.frequency_setting = 0.5
      freq1 = subject.frequency
      subject.frequency_setting = 0.6
      freq2 = subject.frequency
      subject.frequency_setting = 0.7
      (subject.frequency / freq2).should be_within(1e-3).of(freq2 / freq1)
    end

    it "can set frequency directly" do
      subject.frequency_setting = 0.5
      freq1 = subject.frequency
      subject.frequency_setting = 0.6
      subject.frequency = freq1
      subject.frequency_setting.should == 0.5
    end
  end
end