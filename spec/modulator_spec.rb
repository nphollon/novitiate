require 'spec_helper'
require_relative '../app/modulator'
require_relative '../app/oscillator'

describe Modulator do
  let(:oscillator) { Oscillator.new(1, 100) }
  subject { Modulator.new(oscillator, 1, 100) }

  it { should be_kind_of(Oscillator) }

  its(:amount) { should == 0 }

  describe "amount" do
    it "should go as high as 1" do
      subject.amount = 1.5
      subject.amount.should be_within(1e-6).of(1)
    end

    it "should go as low as 0" do
      subject.amount = -1
      subject.amount.should be_within(1e-6).of(0)
    end
  end

  describe "sample" do
    it "should call sample on oscillator" do
      oscillator.should_receive(:sample).with(1).and_return(0)
      subject.sample(1)
    end

    it "should modulate oscillator" do
      oscillator.stub(sample: 0.1)
      subject.amount = 1
      subject.sample(0.01).should be_within(1e-6).of(0.1 * (1-Math.sin(0.2*Math::PI)))
    end
  end
end 