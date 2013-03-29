require 'spec_helper'
require_relative '../app/filter'
require_relative '../app/oscillator'

describe Filter do
  let(:oscillator) { Oscillator.new(1, 100) }
  subject { Filter.new(oscillator, 5) }

  describe "level" do
    its(:level) { should be_within(1e-6).of(1) }

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

  describe "resonance" do
    its(:resonance) { should be_within(1e-6).of(0) }

    it "should be adjustable" do
      subject.resonance = 0.5
      subject.resonance.should be_within(1e-6).of(0.5)
    end

    it "can be set as high as 1" do
      subject.resonance = 1.1
      subject.resonance.should be_within(1e-6).of(1)
    end

    it "can be set as low as 0" do
      subject.resonance = -0.1
      subject.resonance.should be_within(1e-6).of(0)
    end
  end

  describe "sample" do
    it "should call sample on filtered object" do
      oscillator.should_receive(:sample).with(5).and_call_original
      subject.sample(5)
    end

    it "should call update_cache" do
      subject.should_receive(:update_cache)
      subject.sample(5)
    end

    describe "no resonance" do
      it "should use first value in cache based on filter level" do
        oscillator.stub(sample: 0.25)
        subject.level = 0.6
        subject.sample(1)
        subject.update_cache(0.9)
        subject.sample(1).should be_within(1e-6).of(0.6*0.25 + 0.4*0.9)
      end
    end
  end

  describe "cache" do
    its(:cache_size) { should == 5 }
    its(:cache) { should == [0, 0, 0, 0, 0] }
  end

  describe "update_cache" do
    it "should add parameter to cache array" do
      subject.update_cache(1)
      subject.update_cache(-1)
      subject.cache.should == [-1, 1, 0, 0, 0]
    end

    it "should round values > 1 to 1" do
      subject.update_cache(5)
      subject.cache.should == [1, 0, 0, 0, 0]
    end

    it "should round values < -1 to -1" do
      subject.update_cache(-5)
      subject.cache.should == [-1, 0, 0, 0, 0]
    end
  end
end