require 'spec_helper'
require_relative '../app/waveform'

describe "Waveform" do
  describe "initialize" do
    it "should not have a 0-param initializer" do
      expect { Waveform.new }.to raise_error(ArgumentError)
    end
  end

  describe "frequency" do
    subject { Waveform.new(440.0) }

    its(:frequency) { should be_within(1e-6).of(440) }

    it "has a settable frequency" do
      subject.frequency = 7
      subject.frequency.should == 7
    end

    it "cannot be set to 0" do
      expect { subject.frequency = 0 }.to raise_error(RangeError)
    end

    it "cannot be set to less than 0" do
      expect { subject.frequency = -0.5 }.to raise_error(RangeError)
    end
  end

  describe "value_at_phase" do
    subject { Waveform.new(440.0) }

    it "should not have value_at_phase implemented" do
      expect { subject.value_at_phase(0.5) }.to raise_error(NotImplementedError)
    end
  end
end

describe "SineWave" do
  describe "value_at_phase" do
    subject { SineWave.new(1) }

    it "should evaluate to sine" do
      (0...10).each do |i|
        subject.value_at_phase(i/10.0).should be_within(1e-6).of(Math.sin(i*Math::PI/5))
      end
    end
  end
end

describe "SquareWave" do
  describe "value_at_phase" do
    subject { SquareWave.new(1) }

    it "should evaluate to square" do
      (0...10).each do |i|
        subject.value_at_phase(i/20.0).should be_within(1e-6).of(-1)
        subject.value_at_phase(i/20.0 + 0.51).should be_within(1e-6).of(1)
      end
    end
  end
end

describe "TriangleWave" do
  describe "value_at_phase" do
    subject { TriangleWave.new(1) }

    it "should evaluate to triangle" do
      (0...10).each do |i|
        subject.value_at_phase(i/20.0).should be_within(1e-6).of(i/5.0 - 1)
        subject.value_at_phase(i/20.0 + 0.5).should be_within(1e-6).of(-i/5.0 + 1)
      end
    end
  end
end

describe "SawtoothWave" do
  describe "value_at_phase" do
    subject { SawtoothWave.new(1) }

    it "should evaluate to sawtooth" do
      (0...10).each do |i|
        subject.value_at_phase(i/10.0).should be_within(1e-6).of(i/5.0 - 1)
      end
    end
  end
end

describe "SmoothSquareWave" do
  describe "value_at_phase" do
    subject { SmoothSquareWave.new(1) }

    it "should evaluate to square wave at most points" do
      (0...10).each do |i|
        subject.value_at_phase(i/20.0 + 0.05).should be_within(1e-6).of(-1)
        subject.value_at_phase(i/20.0 + 0.55).should be_within(1e-6).of(1)
      end
    end

    it "should not have large discontinuities" do
      (0...1000).each do |i|
        subject.value_at_phase(i*1e-3).should be_within(0.1).of(subject.value_at_phase((i+1)*1e-3))
      end
    end

    it "should be continuous from phase 1 to phase 0" do
      subject.value_at_phase(1).should be_within(1e-6).of(subject.value_at_phase(0))
    end
  end
end


describe "SmoothSawtoothWave" do
  describe "value_at_phase" do
    subject { SmoothSawtoothWave.new(1) }

    it "should not have large discontinuities" do
      (0...1000).each do |i|
        subject.value_at_phase(i*1e-3).should be_within(0.1).of(subject.value_at_phase((i+1)*1e-3))
      end
    end

    it "should be continuous from phase 1 to phase 0" do
      subject.value_at_phase(1).should be_within(1e-6).of(subject.value_at_phase(0))
    end
  end
end