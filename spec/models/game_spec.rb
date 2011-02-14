require 'spec_helper'

module Model
  describe Game do
    before(:each) do
      @simulator = make_simulator_with_game
    end

    describe "kill_references" do
      it "should kill game schedulers" do
        GameScheduler.make(:game_id => @simulator.games.first.id)
        @simulator.games.first.destroy
        GameScheduler.first.should == nil
      end

      it "should kill adjustment coefficient records" do
        AdjustmentCoefficientRecord.destroy_all
        AdjustmentCoefficientRecord.create(:game_id => @simulator.games.first.id)
        AdjustmentCoefficientRecord.first.should_not == nil
        @simulator.games.first.destroy
        AdjustmentCoefficientRecord.first.should == nil
      end
    end
  end
end