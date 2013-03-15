require 'spec_helper'
require_relative '../../ruby-portaudio/lib/portaudio'

describe Speaker do
  subject { Speaker.new(output: :mute, buffer_size: 1024) }
  
  it { should respond_to(:buffer) }
  it { should respond_to(:output) }
  its(:buffer) { should respond_to(:fill) }

  describe "initialize" do
    it "should have default output by default" do
      Speaker.new.output.should == :default
    end

    it "should take output type as a parameter" do
      Speaker.new(output: :mute).output.should == :mute
    end
  end

  describe "device" do
    it "should not have an initialized device" do
      expect { subject.device }.to raise_error(PortAudio::APIError)
    end
  end

  describe "time_step" do
    it "should not have an initialized time_step" do
      expect { subject.time_step }.to raise_error(PortAudio::APIError)
    end
  end

  describe "stream" do
    it "should not have an initialized stream" do
      expect { subject.stream }.to raise_error(PortAudio::APIError)
    end
  end

  describe "turn_on" do
    after do
      begin
        subject.turn_off
      rescue PortAudio::APIError
      end
    end

    it "should call PortAudio.init" do
      device_double = double(default_sample_rate: 1.0, open_stream: :nil)
      PortAudio.stub(:default_output_device).and_return(device_double)
      PortAudio.should_receive(:init)
      subject.turn_on
    end

    describe "initializing PortAudio objects" do
      before { subject.turn_on }

      it "should initialize a device" do
        subject.device.should respond_to(:open_stream)
      end

      it "should initialize a time_step" do
        expected_time_step = subject.device.default_sample_rate ** -1
        subject.time_step.should be_within(1e-10).of(expected_time_step)
      end

      it "should initialize a stream" do
        subject.stream.should respond_to(:start)
      end
    end
  end

  describe "turn_off" do
    it "should call PortAudio.terminate" do
      PortAudio.should_receive(:terminate)
      subject.turn_off
    end

    describe "disposing of PortAudio objects" do
      before do
        subject.turn_on
        subject.turn_off
      end

      it "should no longer have a device" do
        expect { subject.device }.to raise_error(PortAudio::APIError)
      end

      it "should no longer have a time_step" do
        expect { subject.time_step }.to raise_error(PortAudio::APIError)
      end

      it "should no longer have a stream" do
        expect { subject.stream }.to raise_error(PortAudio::APIError)
      end
    end    
  end

  describe "fill_buffer" do
    before do
      subject.turn_on
    end

    after do
      subject.turn_off
    end

    it "should call sample on its parameter" do
      sampleable = double
      sampleable.should_receive(:sample).
        exactly(subject.buffer.frames).times.
        with(subject.time_step).
        and_return(0)
      subject.fill_buffer(sampleable)
    end

    it "should fill its buffer" do
      sampleable = double(sample: 0)
      subject.fill_buffer(sampleable)
      subject.buffer.each do |f,c,s|
        s.should be_within(1e-10).of(0)
      end
    end
  end

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
      subject.turn_on
      sampleable = double(sample: 1)
      subject.gain = 0
      subject.fill_buffer(sampleable)
      subject.buffer.each do |f,c,s|
        s.should be_within(1e-10).of(0)
      end
      subject.turn_off
    end
  end

  describe "play" do
    let(:sampleable) { double(sample: 0) }

    before { subject.turn_on }

    it "should start the stream" do
      subject.stream.should_receive(:start).and_call_original
      subject.play(0, sampleable) 
    end

    it "should stop the stream" do
      subject.stream.should_receive(:stop).and_call_original
      subject.play(0, sampleable) 
    end

    xit "should yield to a block and pass a parameter" do
      @i = 10
      subject.play(1e-5, sampleable) { |t| @i = t }
      @i.should be_within(1e-10).of(0)
    end

    xit "should yield multiple times based on parameter" do
      STDOUT.should_receive(:puts).with("test").exactly(5).times
      subject.play(0.11, sampleable) { puts "test"}
    end

    it "should fill its buffer multiple times based on parameter" do
      subject.should_receive(:fill_buffer).exactly(5).times
      subject.play(0.11, sampleable) 
    end

    describe "loud speaker" do
      subject { Speaker.new(buffer_size: 1024) }
      it "should pass its buffer to its stream after being filled" do
        subject.stream.should_receive(:<<).with(subject.buffer).exactly(5).times
        subject.play(0.11, sampleable) 
      end
    end

    describe "mute speaker" do
      it "should never write to its stream" do
        subject.stream.should_receive(:<<).exactly(0).times
        subject.play(0.11, sampleable) 
      end
    end

    after { subject.turn_off}
  end
end