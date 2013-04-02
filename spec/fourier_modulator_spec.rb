require 'spec_helper'
require_relative '../app/fourier_series'
require_relative '../app/fourier_modulator'

describe "FourierModulator" do
  let (:oscillator) { FourierSeries.new(440) }
  let (:modulator) { FourierModulator.new(20, oscillator) }
  subject { modulator }

  its (:lfo_fundamental) { should == 20 }
  its (:lfo_bandwidth_limit) { should == 10_000 }
  its (:lfo_coefficients) { should == [[1],[0]]}

  describe "modulation_amount" do
    its (:modulation_amount) { should == 0 }

    it "is settable" do
      subject.modulation_amount = 0.5
      subject.modulation_amount.should be_within(1e-6).of(0.5)
    end

    it "cannot be set lower than 0" do
      subject.modulation_amount = -0.1
      subject.modulation_amount.should be_within(1e-6).of(0)
    end

    it "cannot be set higher than 1" do
      subject.modulation_amount = 1.1
      subject.modulation_amount.should be_within(1e-6).of(1)
    end
  end

  describe "sample" do
    describe "modulation amount = 0" do
      it "samples the oscillator" do
        time_step = 44100**-1
        (0..10).each do |i|
          subject.sample(time_step).should be_within(1e-6).of(Math.sin(2*Math::PI * 440 * (i+1)*time_step))
        end
      end
    end

    describe "modulation amount = 1" do
      before { subject.modulation_amount = 1 }

      it "modulates the oscillator with the LFO" do
        time_step = 44100**-1
        (0..10).each do |i|
          subject.sample(time_step).should be_within(1e-6).of(
            Math.sin(2*Math::PI * 20 * (i+1)*time_step) * Math.sin(2*Math::PI * 440 * (i+1)*time_step)
          )
        end
      end
    end

    describe "modulation amount = 0.5" do
      before { subject.modulation_amount = 0.5 }

      it "modulates the oscillator with the LFO at half-amplitude" do
        time_step = 44100**-1
        (0..10).each do |i|
          subject.sample(time_step).should be_within(1e-6).of(
            Math.sin(2*Math::PI*440*(i+1)*time_step) * (0.5 + 0.5*Math.sin(2*Math::PI*20*(i+1)*time_step))
          )
        end
      end
    end
  end

  describe "set_lfo_waveform" do
    before { oscillator.fundamental = 20 }

    specify "sine wave" do
      oscillator.set_to(:sine, 15)
      modulator.set_lfo_waveform(:sine, 15)
      modulator.lfo_coefficients.should == oscillator.coefficients
    end

    specify "triangle wave" do
      oscillator.set_to(:triangle, 15)
      modulator.set_lfo_waveform(:triangle, 15)
      modulator.lfo_coefficients.should == oscillator.coefficients
    end

    specify "square wave" do
      oscillator.set_to(:square, 15)
      modulator.set_lfo_waveform(:square, 15)
      modulator.lfo_coefficients.should == oscillator.coefficients
    end

    specify "sawtooth wave" do
      oscillator.set_to(:sawtooth, 15)
      modulator.set_lfo_waveform(:sawtooth, 15)
      modulator.lfo_coefficients.should == oscillator.coefficients
    end
  end
end