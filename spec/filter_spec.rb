require 'spec_helper'
require_relative '../app/filter'
require_relative '../app/oscillator'

describe Filter do
  let(:oscillator) { Oscillator.new(1, 100) }
  subject { Filter.new(oscillator) }

  describe "level" do
    its(:level) { should be_within(1e-6).of(0) }

    it "should be adjustable" do
      subject.level = 0.5
      subject.level.should be_within(1e-6).of(0.5)
    end

    it "can be set as high as 1" do
      subject.level = 1.1
      subject.level.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      subject.level = -0.1
      subject.level.should be_within(1e-6).of(0)
    end
  end

  describe "resonance_amount" do
    its(:resonance_amount) { should be_within(1e-6).of(0) }

    it "should be adjustable" do
      subject.resonance_amount = 0.5
      subject.resonance_amount.should be_within(1e-6).of(0.5)
    end

    it "can be set as high as 1" do
      subject.resonance_amount = 1.1
      subject.resonance_amount.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      subject.resonance_amount = -0.1
      subject.resonance_amount.should be_within(1e-6).of(0)
    end
  end

  describe "sample" do
    it "should call sample on filtered object" do
      oscillator.should_receive(:sample).with(5).and_call_original
      subject.sample(5)
    end
  end
end