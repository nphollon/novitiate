require 'spec_helper'
require_relative '../app/compound_fourier_series'

describe "CompoundFourierSeries" do
  let(:fourier1) { FourierSeries.new(440) }
  let(:fourier2) { FourierSeries.new(23) }
  let(:compound) { CompoundFourierSeries.new(fourier1, fourier2) }
  subject { compound }

  its(:components) { should == [fourier1, fourier2] }

  describe "sample" do
    it "samples the product of its component functions" do
      fourier1.coefficients = [[2,3],[5,7]]
      fourier2.coefficients = [[11,13],[17,19]]
      compound.sample(1e-3).should be_within(1e-6).of 0.5 * (
        (2*17+5*11) * Math.sin(2*Math::PI*1e-3*(440+23)) + (5*17-2*11) * Math.cos(2*Math::PI*1e-3*(440+23)) +
        (2*17-5*11) * Math.sin(2*Math::PI*1e-3*(440-23)) + (5*17+2*11) * Math.cos(2*Math::PI*1e-3*(440-23)) +

        (3*17+7*11) * Math.sin(2*Math::PI*1e-3*(2*440+23)) + (7*17-3*11) * Math.cos(2*Math::PI*1e-3*(2*440+23)) +
        (3*17-7*11) * Math.sin(2*Math::PI*1e-3*(2*440-23)) + (7*17+3*11) * Math.cos(2*Math::PI*1e-3*(2*440-23)) +

        (2*19+5*13) * Math.sin(2*Math::PI*1e-3*(440+2*23)) + (5*19-2*13) * Math.cos(2*Math::PI*1e-3*(440+2*23)) +
        (2*19-5*13) * Math.sin(2*Math::PI*1e-3*(440-2*23)) + (5*19+2*13) * Math.cos(2*Math::PI*1e-3*(440-2*23)) +

        (3*19+7*13) * Math.sin(2*Math::PI*1e-3*(2*440+2*23)) + (7*19-3*13) * Math.cos(2*Math::PI*1e-3*(2*440+2*23)) +
        (3*19-7*13) * Math.sin(2*Math::PI*1e-3*(2*440-2*23)) + (7*19+3*13) * Math.cos(2*Math::PI*1e-3*(2*440-2*23))
      )
    end

    specify "when odd and even coefficient arrays are different lengths" do
      fourier1.coefficients = [[2], [5,7]]
      fourier2.coefficients = [[11,13], [17]]
      compound.sample(1e-3).should be_within(1e-6).of 0.5 * (
        (2*17+5*11) * Math.sin(2*Math::PI*1e-3*(440+23)) + (5*17-2*11) * Math.cos(2*Math::PI*1e-3*(440+23)) +
        (2*17-5*11) * Math.sin(2*Math::PI*1e-3*(440-23)) + (5*17+2*11) * Math.cos(2*Math::PI*1e-3*(440-23)) +

        (7*11) * Math.sin(2*Math::PI*1e-3*(2*440+23)) + (7*17) * Math.cos(2*Math::PI*1e-3*(2*440+23)) +
        (-7*11) * Math.sin(2*Math::PI*1e-3*(2*440-23)) + (7*17) * Math.cos(2*Math::PI*1e-3*(2*440-23)) +

        (5*13) * Math.sin(2*Math::PI*1e-3*(440+2*23)) + (-2*13) * Math.cos(2*Math::PI*1e-3*(440+2*23)) +
        (-5*13) * Math.sin(2*Math::PI*1e-3*(440-2*23)) + (2*13) * Math.cos(2*Math::PI*1e-3*(440-2*23)) +

        (7*13) * Math.sin(2*Math::PI*1e-3*(2*440+2*23)) +
        (-7*13) * Math.sin(2*Math::PI*1e-3*(2*440-2*23))
      )
    end

    it "increments time by sample size" do
      compound.sample(1e-3)
      compound.sample(1e-3).should be_within(1e-6).of 0.5 * (
        -Math.cos(2*Math::PI*2e-3*(440+23)) + Math.cos(2*Math::PI*2e-3*(440-23))
      )
    end

    it "increments phase by sample size * frequency, even if frequency changes" do
      compound.sample(1e-3)
      fourier1.fundamental = 300
      fourier2.fundamental = 41
      compound.sample(1e-3).should be_within(1e-6).of 0.5 * (
        -Math.cos(2*Math::PI*1e-3*(440+23+300+41)) + Math.cos(2*Math::PI*1e-3*(440-23+300-41))
      )
    end
  end
end