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
    it { should be_silent }
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
  end

end