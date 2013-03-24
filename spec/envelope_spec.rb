require 'spec_helper'
require_relative '../app/speaker'
require_relative '../app/envelope'
require_relative '../app/oscillator'

describe "Envelope" do
  let (:speaker) { Speaker.new(mute: true) }
  let (:oscillator) { double(sample: 1.0) }
  subject { Envelope.new(oscillator) }

  describe "fire" do
    it "calls play on the provided speaker" do
      speaker.should_receive(:play).with(1, subject)
      subject.fire(speaker)
    end

    it "sends its duration to 'play'" do
      speaker.should_receive(:play).with(10, subject)
      subject.attack = 1
      subject.decay = 2
      subject.hold = 3
      subject.release = 4
      subject.fire(speaker)
    end
  end

  describe "sample" do
    describe "ADR = 0" do
      subject { Envelope.new(Oscillator.new(1,100)) }
      it "returns the oscillator value if S = 1.0" do
        subject.sample(0.003).should be_within(1e-6).of(Math.sin(20 * 0.003 * Math::PI))
      end

      it "returns half the oscillator value if S = 0.5" do
        subject.sustain = 0.5
        subject.sample(0.003).should be_within(1e-6).of(0.5 * Math.sin(20 * 0.003 * Math::PI))
      end
    end

    specify "A = 1, D = 1, H = 1, S = 0.5, R = 1" do
      subject.attack = 1
      subject.decay = 1
      subject.hold = 1
      subject.sustain = 0.5
      subject.release = 1

      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(1 - i*0.05)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5-i*0.05)
      end
    end

    specify "A = 2, D = 1, H = 1, S = 0.5, R = 1" do
      subject.attack = 2
      subject.decay = 1
      subject.hold = 1
      subject.sustain = 0.5
      subject.release = 1

      (1..10).each do |i|
        subject.sample(0.2).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(1 - i*0.05)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5-i*0.05)
      end
    end

    specify "A = 1, D = 2, H = 1, S = 0.5, R = 1" do
      subject.attack = 1
      subject.decay = 2
      subject.hold = 1
      subject.sustain = 0.5
      subject.release = 1

      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.2).should be_within(1e-6).of(1 - i*0.05)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5-i*0.05)
      end
    end

    specify "A = 1, D = 1, H = 2, S = 0.5, R = 1" do
      subject.attack = 1
      subject.decay = 1
      subject.hold = 2
      subject.sustain = 0.5
      subject.release = 1

      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(1 - i*0.05)
      end
      (1..10).each do |i|
        subject.sample(0.2).should be_within(1e-6).of(0.5)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5-i*0.05)
      end
    end

    specify "A = 1, D = 1, H = 1, S = 0.25, R = 1" do
      subject.attack = 1
      subject.decay = 1
      subject.hold = 1
      subject.sustain = 0.25
      subject.release = 1

      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(1 - i*0.075)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.25)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.25-i*0.025)
      end
    end

    specify "A = 1, D = 1, H = 1, S = 0.5, R = 2" do
      subject.attack = 1
      subject.decay = 1
      subject.hold = 1
      subject.sustain = 0.5
      subject.release = 2

      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(i*0.1)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(1 - i*0.05)
      end
      (1..10).each do |i|
        subject.sample(0.1).should be_within(1e-6).of(0.5)
      end
      (1..10).each do |i|
        subject.sample(0.2).should be_within(1e-6).of(0.5-i*0.05)
      end
    end

    it "samples 0 if time_step overshoots the end of the envelope" do
      subject.attack = 1
      subject.decay = 1
      subject.hold = 1
      subject.sustain = 0.5
      subject.release = 1
      subject.sample(5).should be_within(1e-6).of(0)        
    end
  end

  describe "duration" do
    its (:duration) { should == 1 }

    it "is the sum of attack, decay, hold, and release" do
      subject.attack = 1
      subject.decay = 2
      subject.hold = 4
      subject.release = 8
      subject.duration.should == 15
    end
  end

  describe "attack" do
    its(:attack) { should == 0 }

    it "cannot be less than 0" do
      subject.attack = -1
      subject.attack.should == 0
    end

    it "can be a positive value" do
      subject.attack = 5
      subject.attack.should == 5
    end
  end

  describe "decay" do
    its(:decay) { should == 0 }

    it "cannot be less than 0" do
      subject.decay = -1
      subject.decay.should == 0
    end

    it "can be a positive value" do
      subject.decay = 5
      subject.decay.should == 5
    end
  end

  describe "hold" do
    its(:hold) { should == 1 }

    it "cannot be less than 0" do
      subject.hold = -1
      subject.hold.should == 0
    end

    it "can be a positive value" do
      subject.hold = 5
      subject.hold.should == 5
    end
  end

  describe "release" do
    its(:release) { should == 0 }

    it "cannot be less than 0" do
      subject.release = -1
      subject.release.should == 0
    end

    it "can be a positive value" do
      subject.release = 5
      subject.release.should == 5
    end
  end

  describe "sustain" do
    its(:sustain) { should == 1 }    

    it "can be set as high as 1" do
      subject.sustain = 1.1
      subject.sustain.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      subject.sustain = -0.1
      subject.sustain.should be_within(1e-6).of(0)
    end
  end
end