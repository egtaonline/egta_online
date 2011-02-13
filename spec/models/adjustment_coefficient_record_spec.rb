require 'spec_helper'

module Model
  describe AdjustmentCoefficientRecord do
    describe "#calculate_coefficients" do
      before(:each) do
        @simulator = make_simulator_with_game
        @acr = AdjustmentCoefficientRecord.new(:game_id => @simulator.games.first.id)
        @acr.calculate_coefficients([@simulator.games.first.features.first])
      end

      it "creates a feature hash" do
        @acr.feature_hash.should_not == nil
      end

      it "maps from the specified feature to a coefficient" do
        @acr.feature_hash[@simulator.games.first.features.first.name].should_not == nil
        puts @acr.feature_hash[@simulator.games.first.features.first.name]
      end
    end
  end
end