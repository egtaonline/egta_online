require 'spec_helper'

describe Game do
  describe "#initialize" do
    context "with a parameter hash" do
      let!(:game) { Game.new(:parameters => Hash[:a => "a value", :b => "b value"]) }
      it "should create a simulator with parameter fields" do
        game.parameter_fields.should == [:a, :b]
      end
      it "should create fields on the simulator" do
        game[:a].should == "a value"
        game[:b].should == "b value"
      end
    end
  end
  describe "#add_strategy_by_name" do
    let!(:game) { SymmetricGame.new(:name => "new", :size => 2) }
    it "should allow me to add strategies" do
      game.add_strategy_by_name "A"
      game.strategy_array.should == ["A"]
      game.add_strategy_by_name "A"
      game.strategy_array.should == ["A"]
      game.save!
      Game.first.strategy_array.should == ["A"]
    end
  end
end
