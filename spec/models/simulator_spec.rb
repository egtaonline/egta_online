require 'spec_helper'

describe Simulator do
  describe "#add_strategy_by_name" do
    let!(:simulator) { Fabricate(:simulator) }
    it "should allow me to add strategies" do
      simulator.add_strategy_by_name "A"
      simulator.strategy_array.should == ["A"]
      simulator.add_strategy_by_name "A"
      simulator.strategy_array.should == ["A"]
    end
  end
end
