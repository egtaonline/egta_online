require 'spec_helper'

describe Simulator do
  describe "#initialize" do
    context "with a parameter hash" do
      let!(:simulator) { Simulator.new(:parameters => Hash[:a => "a value", :b => "b value"]) }
      it "should create a simulator with parameter fields" do
        simulator.parameter_fields.should == [:a, :b]
      end
      it "should create fields on the simulator" do
        simulator[:a].should == "a value"
        simulator[:b].should == "b value"
      end
    end
  end
  describe "#add_strategy_by_name" do
    let!(:simulator) { Simulator.new(:parameters => Hash[:a => "a value", :b => "b value"]) }
    it "should allow me to add strategies" do
      simulator.add_strategy_by_name "A"
      simulator.strategy_array.should == ["A"]
      simulator.add_strategy_by_name "A"
      simulator.strategy_array.should == ["A"]
    end
  end
end
