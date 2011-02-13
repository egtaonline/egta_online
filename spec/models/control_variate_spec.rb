require 'spec_helper'

module Model
  describe ControlVariate do
    before(:each) do
      @simulator = make_simulator_with_game
      @acr = AdjustmentCoefficientRecord.new(:game_id => @simulator.games.first.id)
      @acr.calculate_coefficients([@simulator.games.first.features.first])
      @control_variate = ControlVariate.new(:adjustment_coefficient_record_id => @acr.id)
      @simulator.games.first.control_variates << @control_variate
      @control_variate.save!
    end
    describe "#copy_game" do
      it "should copy a game" do
        game = @control_variate.copy_game(@simulator.games.first, "cv")
        game.strategies.first.name.should == @simulator.games.first.strategies.first.name
      end
    end
    describe "#transform_game" do
      it "should make a real game" do
        game = @control_variate.transform_game(@simulator.games.first, "cv")
        game.id.should_not == nil
      end
    end
    describe "#apply_cv" do
      it "stores a destination id" do
        @control_variate.apply_cv
        @control_variate.destination_id.should_not == nil
      end

      it "should map to valid destination game" do
        @control_variate.apply_cv
        Game.find(@control_variate.destination_id).should_not == nil
      end

      it "should change the payoff" do
        strategy = @simulator.games.first.strategies.first.name
        @control_variate.apply_cv
        pay = Game.find(@control_variate.destination_id).profiles.first.payoff_to_strategy(strategy)
        pay.should_not == @simulator.games.first.profiles.first.payoff_to_strategy(strategy)
        pay.should_not == 0.0
      end
    end
  end
end