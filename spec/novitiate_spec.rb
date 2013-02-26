require 'spec_helper'
require_relative '../novitiate'

describe "Novitiate" do
  before do
    @nov = Novitiate.new
    @nov.turn_on
  end

  after do
    @nov.turn_off
  end

  subject { @nov }

  describe "oscillation" do
    its (:wave_setting) { should == :sine }
    its (:frequency_setting) { should == 0.5 }
    its (:gain) { should == 1.0 }

    describe "wave_settings" do
      it "gives sine wave output by default" do
        @nov.waveform.class.should == Novitiate::SineWave
      end

      specify "triangle wave setting" do
        @nov.wave_setting = :triangle
        @nov.waveform.class.should == Novitiate::TriangleWave
      end

      specify "square wave setting" do
        @nov.wave_setting = :square
        @nov.waveform.class.should == Novitiate::SquareWave
      end

      specify "sawtooth wave setting" do
        @nov.wave_setting = :sawtooth
        @nov.waveform.class.should == Novitiate::SawtoothWave
      end
    end

    describe "frequency settings" do
      before do
        @freq1 = @nov.frequency
        @nov.frequency_setting = 0.6
      end

      its(:frequency) { should be > @freq1 }
      its(:frequency) { should == @nov.waveform.frequency }

      specify "logarithmically-scaled frequency" do
        freq2 = @nov.frequency
        @nov.frequency_setting = 0.7
        (@nov.frequency / freq2).should be_within(1e-3).of(freq2 / @freq1)
      end

      it "can't have a frequency setting higher than 1" do
        expect { @nov.frequency_setting = 1.001 }.to raise_error(RangeError)
      end

      it "can't have a frequency setting lower than 0" do
        expect { @nov.frequency_setting = -0.001 }.to raise_error(RangeError)
      end
    end

    describe "playing" do

      describe "uint8 format" do
        before do
          @buffer = PortAudio::SampleBuffer.new(format: :uint8)
        end

        describe "filling buffer with waveform samples" do
          specify "square wave" do
            @nov.wave_setting = :square
            @nov.fill_buffer(@buffer)
            (0...@buffer.frames).each do |i|
              [0, 255].include?(@buffer[i,0]).should be_true
            end
          end

          specify "sawtooth wave" do
            @nov.wave_setting = :sawtooth
            @nov.fill_buffer(@buffer)
            (@buffer[10,0] - @buffer[0,0]).should be > 0
          end
        end
      end

      describe "int8 format" do
        before do
          @buffer = PortAudio::SampleBuffer.new(format: :int8)
        end

        it "should give samples in the appropriate range" do
          @nov.wave_setting = :square
          @nov.fill_buffer(@buffer)
          (0...@buffer.frames).each do |i|
            [-128, 127].include?(@buffer[i,0]).should be_true
          end
        end
      end

      describe "buffer continuity" do
        it "should keeps track of where it left off when filling multiple buffers" do
          buffer = PortAudio::SampleBuffer.new(format: :int16)
          @nov.wave_setting = :sawtooth
          @nov.fill_buffer(buffer)
          sample1 = buffer[0,0]
          @nov.fill_buffer(buffer)
          buffer[0,0].should be > sample1
        end
      end
    end
  end
end