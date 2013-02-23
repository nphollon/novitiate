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
  end

end