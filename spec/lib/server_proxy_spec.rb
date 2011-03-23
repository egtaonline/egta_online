require 'spec_helper'

module Lib
  describe ServerProxy do
    before(:each){@proxy = ServerProxy.new}
    describe "#gather_simulation" do
      before(:each) do
        @simulator = Simulator.make
        @simulator.strategies.create(:name => "BayesianPricing:noRA:0.0")
        @game = Game.make(:simulator_id => @simulator.id)
        @game.add_strategy(@simulator.strategies.first)
        SimCount.make
        @simulation = Simulation.make(:size => 60, :state => "complete", :profile_id => @game.profiles.first.id, :game_id => @game.id)
      end
      it "should add samples to the simulation" do
        @proxy.gather_samples(@simulation)
        @simulation.samples.count.should == 60
      end
    end
  end
end