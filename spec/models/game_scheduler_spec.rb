require 'spec_helper'

describe GameScheduler do
  describe "#schedule" do
    before(:each) do
      Account.make
      @game = make_game_with_descendents
      @game.game_schedulers << GameScheduler.make
      @game.game_schedulers.first.schedule
    end
    it  "should schedule a simulation for the game" do
      @game.simulations.count.should == 1
    end
    it "should create proper associations between profiles and simulations" do
      @game.profiles.first.scheduled_count.should == 30
    end
  end
  describe "#schedule_failed" do
    before(:each) do
      Account.make(:max_concurrent_simulations => 0)
      @game = make_game_with_descendents
      @game.game_schedulers << GameScheduler.make
    end
    it "should not schedule a game when the account does not have sufficient simulation space" do
      Account.first.max_concurrent_simulations.should == 0
      @game.game_schedulers.first.schedule
      @game.simulations.count.should == 0
      @game.profiles.first.scheduled_count.should == 0
    end
  end
end
