require 'spec_helper'
require_relative '../app/speaker'
require_relative '../../ruby-portaudio/portaudio'

describe "Speaker" do
  subject { Speaker.new(mute: true, buffer_size: 1024) }

  describe "mute" do
    it "should have unmuted output by default" do
      Speaker.new.mute.should be_false
    end

    it "should be mute if initialized with mute option" do
      Speaker.new(mute: true).mute.should be_true
    end
  end

  its (:time_step) { should be_within(1e-10).of(subject.stream.sample_rate**-1)}

  describe "gain" do
    it "should not set gain higher than 1.0" do
      subject.gain = 1.1
      subject.gain.should be_within(1e-6).of(1)
    end

    it "should not set gain lower than 0.0" do
      subject.gain = -0.1
      subject.gain.should be_within(1e-6).of(0)
    end

    it "should be silent when gain is set to zero" do
      sampleable = double(sample: 1)
      subject.gain = 0
      subject.play(1e-5, sampleable)
      subject.buffer.each do |s|
        s.should be_within(1e-10).of(0)
      end
    end

    it "should be at half max volume when gain is set to 0.5" do
      sampleable = double(sample: 1)
      subject.gain = 0.5
      subject.play(1e-5, sampleable)
      subject.buffer.each do |s|
        s.should be_within(1e-10).of(0.5)
      end
    end
  end

  describe "play" do
    let(:sampleable) { double(sample: 0) }

    it "should start the stream" do
      subject.stream.should_receive(:start).and_call_original
      subject.play(0, sampleable) 
    end

    it "should stop the stream" do
      subject.stream.should_receive(:stop).and_call_original
      subject.play(0, sampleable) 
    end

    it "should call sample on its parameter" do
      sampleable = double
      sampleable.should_receive(:sample).
        exactly(subject.buffer.length).times.
        with(subject.time_step).
        and_return(0)
      subject.play(1e-5, sampleable)
    end

    it "should fill its buffer multiple times based on parameter" do
      sampleable = double
      sampleable.should_receive(:sample).
        exactly(subject.buffer.length * 5).times.
        with(subject.time_step).
        and_return(0)
      subject.play(0.11, sampleable) 
    end

    it "should fill its buffer" do
      sampleable = double(sample: 0)
      subject.play(1e-5, sampleable)
      subject.buffer.each do |s|
        s.should be_within(1e-10).of(0)
      end
    end
  end
end