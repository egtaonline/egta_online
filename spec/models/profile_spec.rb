require 'spec_helper'

module Model
  describe Profile do
    before(:each) do
      Game.destroy_all
      @simulator = make_simulator_with_game
    end

    describe "kill_references" do
      it "should kill simulation" do
        @account = Account.make
        @simulator.games.first.game_schedulers << GameScheduler.make
        @simulator.games.first.game_schedulers.first.schedule 1
        Game.first.simulations.first.should_not == nil
        Game.first.simulations.should_not == nil
        Game.first.simulations.count.should == 1
        Game.first.profiles.first.should_not == nil
        Game.first.simulations.should_not == nil
        Game.first.profiles.first.destroy
        Game.first.simulations.count.should == 0
      end
    end
  end
end