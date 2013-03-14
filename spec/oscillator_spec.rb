require 'spec_helper'
require_relative '../app/oscillator'

describe Oscillator do
  subject { Oscillator.new(10, 1000, 0.5) }

  its (:frequency_setting) { should == 0.5 }
  its (:min_frequency) { should == 10 }
  its (:max_frequency) { should == 1000 }

  describe "wave_setting" do
    its (:wave_setting) { should == :sine }
         
    it "can be a square" do
      subject.wave_setting = :square
      subject.wave_setting.should == :square
    end

    it "can be a triangle" do
      subject.wave_setting = :triangle
      subject.wave_setting.should == :triangle
    end

    it "can be a sawtooth" do
      subject.wave_setting = :sawtooth
      subject.wave_setting.should == :sawtooth
    end

    it "cannot be anything else" do
      subject.wave_setting = :invalid
      subject.wave_setting.should == :sine
    end
  end

  describe "sample" do
    it "should call get_phase" do
      subject.should_receive(:get_phase).with(1).and_call_original
      subject.sample(1)
    end

    it "should call sample_:waveform" do
      subject.stub(:get_phase).and_return(0.5)
      subject.should_receive(:sample_sine).with(0.5)
      subject.sample(1)
    end

    describe "accumulating time steps" do
      before { subject.sample(5) }

      it "should add sample parameter to running total" do
        subject.should_receive(:get_phase).with(10).and_call_original
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
    specify "min frequency corresponds to freq setting 0" do
      subject.frequency_setting = 0.0
      subject.frequency.should be_within(1e-3).of(10)
    end

    specify "max frequency corresponds to freq setting 1" do
      subject.frequency_setting = 1.0
      subject.frequency.should be_within(1e-3).of(1000)
    end

    it "maxes out at freq setting 1" do
      subject.frequency_setting = 2.0
      subject.frequency.should be_within(1e-3).of(1000)
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