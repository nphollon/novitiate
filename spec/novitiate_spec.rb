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

  describe "defaults" do
    its (:osc_wave_setting) { should == :sine }
    its (:osc_freq_setting) { should == 0.5 }
    its (:mod_wave_setting) { should == :sine }
    its (:mod_freq_setting) { should == 0.0 }
    its (:gain) { should == 1.0 }
    its (:step) { should == 44100.0**-1 }
  end

  describe "oscillation" do
    describe "wave_settings" do
      it "gives sine wave output by default" do
        @nov.osc_waveform.class.should == Novitiate::SineWave
      end

      specify "triangle wave setting" do
        @nov.osc_wave_setting = :triangle
        @nov.osc_waveform.class.should == Novitiate::TriangleWave
      end

      specify "square wave setting" do
        @nov.osc_wave_setting = :square
        @nov.osc_waveform.class.should == Novitiate::SquareWave
      end

      specify "sawtooth wave setting" do
        @nov.osc_wave_setting = :sawtooth
        @nov.osc_waveform.class.should == Novitiate::SawtoothWave
      end
    end

    describe "frequency settings" do
      before do
        @freq1 = @nov.osc_frequency
        @nov.osc_freq_setting = 0.6
      end

      its(:osc_frequency) { should be > @freq1 }
      its(:osc_frequency) { should == @nov.osc_waveform.frequency }

      specify "logarithmically-scaled frequency" do
        freq2 = @nov.osc_frequency
        @nov.osc_freq_setting = 0.7
        (@nov.osc_frequency / freq2).should be_within(1e-3).of(freq2 / @freq1)
      end

      it "can't have a frequency setting higher than 1" do
        expect { @nov.osc_freq_setting = 1.001 }.to raise_error(RangeError)
      end

      it "can't have a frequency setting lower than 0" do
        expect { @nov.osc_freq_setting = -0.001 }.to raise_error(RangeError)
      end

      it "can turn frequency knob in units of octaves per second" do
        freq2 = @nov.osc_frequency
        @nov.slew_frequency(1)
        @nov.osc_frequency.should be_within(1e-6).of(1.0162250658168974*freq2)
      end

      it "can set frequency directly" do
        @nov.osc_frequency = @freq1
        @nov.osc_freq_setting.should == 0.5
      end
    end
  end

  describe "modulation" do
    describe "wave_settings" do
      it "gives sine wave output by default" do
        @nov.mod_waveform.class.should == Novitiate::SineWave
      end

      specify "triangle wave setting" do
        @nov.mod_wave_setting = :triangle
        @nov.mod_waveform.class.should == Novitiate::TriangleWave
      end

      specify "square wave setting" do
        @nov.mod_wave_setting = :square
        @nov.mod_waveform.class.should == Novitiate::SquareWave
      end

      specify "sawtooth wave setting" do
        @nov.mod_wave_setting = :sawtooth
        @nov.mod_waveform.class.should == Novitiate::SawtoothWave
      end
    end

    describe "frequency settings" do
      before do
        @freq1 = @nov.mod_frequency
        @nov.mod_freq_setting = 0.1
      end

      its(:mod_frequency) { should be > @freq1 }
      its(:mod_frequency) { should == @nov.mod_waveform.frequency }

      specify "logarithmically-scaled frequency" do
        freq2 = @nov.mod_frequency
        @nov.mod_freq_setting = 0.2
        (@nov.mod_frequency / freq2).should be_within(1e-3).of(freq2 / @freq1)
      end

      it "can't have a frequency setting higher than 1" do
        expect { @nov.mod_freq_setting = 1.001 }.to raise_error(RangeError)
      end

      it "can't have a frequency setting lower than 0" do
        expect { @nov.mod_freq_setting = -0.001 }.to raise_error(RangeError)
      end

      it "can set frequency directly" do
        @nov.mod_frequency = @freq1
        @nov.mod_freq_setting.should == 0.0
      end
    end
  end

  describe "gain settings" do
    before do
      @nov.osc_wave_setting = :square
      @nov.osc_freq_setting = 1.0
    end

    describe "full gain" do
      it "should have samples in (-1..1)" do
        @nov.fill_buffer
        (0...@nov.buffer.frames).each do |i|
          @nov.buffer[i,0].abs.should be_within(1e-3).of(1)
        end
      end
    end

    describe "half gain" do
      it "should have samples in (-0.5..0.5)" do
        @nov.gain = 0.5
        @nov.fill_buffer
        (0...@nov.buffer.frames).each do |i|
          @nov.buffer[i,0].abs.should be_within(1e-3).of(0.5)
        end
      end
    end
  end

  describe "playing" do
    describe "buffer continuity" do
      it "should keep track of where it left off when filling multiple buffers" do
        @nov.osc_wave_setting = :sawtooth
        @nov.fill_buffer
        sample1 = @nov.buffer[@nov.buffer.frames-1,0]
        @nov.fill_buffer
        @nov.buffer[0,0].should be_within(1e-6).of(sample1 + @nov.osc_frequency/22050.0)
      end
    end
  end
end