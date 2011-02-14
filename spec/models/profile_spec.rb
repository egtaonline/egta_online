require 'spec_helper'

module Model
  describe Profile do
    before(:each) do
      Game.destroy_all
      @simulator = make_simulator_with_game
    end

    describe "kill_references" do
      it "should kill simulation" do
        GameScheduler.destroy_all
        Simulation.destroy_all
        @account = Account.make
        @game_scheduler = GameScheduler.make(:game_id => @simulator.games.first.id)
        @game_scheduler.save!
        @game_scheduler.schedule 1
        Game.first.profiles.first.simulations.first.should_not == nil
        Simulation.first.should_not == nil
        Simulation.all.count.should == 1
        Simulation.first.should == Game.first.profiles.first.simulations.first
        Game.first.profiles.first.should_not == nil
        Game.first.profiles.first.simulations.should_not == nil
        Game.first.profiles.first.destroy
        Simulation.first.should == nil
      end
    end
  end
end