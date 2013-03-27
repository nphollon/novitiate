require 'spec_helper'
require_relative '../app/fourier'

describe "FourierSeries" do
  describe "delta function" do
    subject { FourierSeries.new(440) }

    its(:bandwidth_limit) { should be_within(1e-6).of(1e4) }
    its(:fundamental) { should be_within(1e-6).of(440) }
    its(:coefficients) { should == [[1],[0]]}

    describe "sample" do
      it "samples a sine wave" do
        subject.sample(0.01).should be_within(1e-6).of(Math.sin(8.8*Math::PI))
      end

      it "increments time by sample size" do
        subject.sample(0.01)
        subject.sample(0.01).should be_within(1e-6).of(Math.sin(17.6*Math::PI))
      end

      it "increments phase by sample size * frequency, even if frequency changes" do
        subject.sample(0.01)
        subject.fundamental = 600
        subject.sample(0.01).should be_within(1e-6).of(Math.sin(20.8 * Math::PI))
      end
    end
  end

  describe "finite series" do
    subject { FourierSeries.new(440) }

    describe "coefficients=" do
      it "should set the coefficients" do
        subject.coefficients = [[1],[3]]
        subject.coefficients.should == [[1], [3]]
      end

      it "should pad the arrays with zeros if parameters have a shorter length" do
        subject.coefficients = [[],[]]
        subject.coefficients.should == [[0], [0]]
      end

      it "should extend the arrays if parameters have a longer length" do
        subject.coefficients = [[1, 1, 5], [7, 8, 9]]
        subject.coefficients.should == [[1, 1, 5], [7, 8, 9]]
      end
    end

    describe "sample" do
      it "computes Fourier series and samples resulting function" do
        subject.coefficients = [[1,2],[3,4]]
        subject.sample(0.01).should be_within(1e-6).of(
          Math.sin(8.8*Math::PI) + 2*Math.sin(17.6*Math::PI) +
          3*Math.cos(8.8*Math::PI) + 4*Math.cos(17.6*Math::PI)
        )
      end

      it "ignores frequencies that are above the bandwidth limit" do
        subject.coefficients = [[1, 1], [0, 1]]
        subject.bandwidth_limit = 500
        subject.sample(0.01).should be_within(1e-6).of(Math.sin(8.8*Math::PI))
      end
    end
  end

  describe "presets" do
  end
end