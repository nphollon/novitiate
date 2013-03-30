require 'spec_helper'
require_relative '../app/fourier_series'

describe "FourierSeries" do
  subject { FourierSeries.new(440) }

  describe "delta function" do
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
        subject.coefficients = [[1,2,5],[3,4]]
        subject.sample(0.01).should be_within(1e-6).of(
          Math.sin(8.8*Math::PI) + 2*Math.sin(17.6*Math::PI) + 5*Math.sin(26.4*Math::PI) +
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

  describe "max_coeff_index" do
    it "returns even coefficient count if there are more even than odd" do
      subject.coefficients = [[1], [2, 3, 4]]
      subject.max_coeff_index.should == 3
    end

    it "returns odd coefficient count if there are more odd than even" do
      subject.coefficients = [[5,6],[]]
      subject.max_coeff_index.should == 2
    end
  end

  describe "odd_coefficient" do
    before { subject.coefficients = [[5, 4], []] }

    it "returns coefficient at index" do
      subject.odd_coefficient(0).should == 5
      subject.odd_coefficient(1).should == 4
    end

    it "returns 0 if index is out of bounds" do
      subject.odd_coefficient(2).should == 0
    end
  end

  describe "even_coefficient" do
    before { subject.coefficients = [[], [5, 4]] }

    it "returns coefficient at index" do
      subject.even_coefficient(0).should == 5
      subject.even_coefficient(1).should == 4
    end

    it "returns 0 if index is out of bounds" do
      subject.even_coefficient(2).should == 0
    end
  end

  describe "set_to" do
    before { subject.coefficients = [[1, 1], [1, 1]] }

    specify ":arbitrary_symbol" do
      expect do
        subject.set_to :arbitrary_symbol, 1
      end.to raise_error(KeyError, "Symbol does not match a recognized waveform")
    end

    specify ":sine" do
      subject.set_to :sine, 1
      subject.coefficients.should == [[1, 0], [0, 0]]
    end

    describe ":triangle" do
      it "should set the top 5 sine coefficients if passed a 5" do
        subject.set_to :triangle, 5
        coefficients = subject.coefficients[0]
        coefficients.length.should == 5
      end

      it "should set the top 10 sine coefficients if passed a 10" do
        subject.set_to :triangle, 10
        coefficients = subject.coefficients[0]
        coefficients.length.should == 10
      end

      it "should set coefficients to triangle wave coefficients" do
        subject.set_to :triangle, 15
        coefficients = subject.coefficients[0]
        (0...coefficients.length).each do |i|
          if i % 2 == 1
            coefficients[i].should be_within(1e-6).of(0)
          else
            coefficients[i].should be_within(1e-6).of(8/Math::PI**2/(i+1)**2 * (-1)**(i/2))
          end
        end
        subject.coefficients[1].should == [0, 0]
      end
    end

    describe ":square" do
      it "should set coefficients to square wave coefficients" do
        subject.set_to :square, 15
        coefficients = subject.coefficients[0]
        (0...coefficients.length).each do |i|
          if i % 2 == 1
            coefficients[i].should be_within(1e-6).of(0)
          else
            coefficients[i].should be_within(1e-6).of(4/Math::PI/(i+1))
          end
        end
      end
    end

    describe ":sawtooth" do
      it "should set coefficients to sawtooth wave coefficients" do
        subject.set_to :sawtooth, 15
        coefficients = subject.coefficients[0]
        (0...coefficients.length).each do |i|
          coefficients[i].should be_within(1e-6).of(2/Math::PI/(i+1)*(-1)**i)
        end
      end
    end
  end
end