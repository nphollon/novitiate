require 'spec_helper'
require_relative '../app/envelope'

describe Envelope do
  subject { Envelope.new }
  
  describe "sample" do
    it "should return 0" do
      subject.sample(0).should == 0
    end
  end
end