require 'spec_helper'

describe "#find_games" do
  before do
    ResqueSpec.reset!
  end

  it "should associate a profile to a game" do
    simulator = Fabricate(:simulator)
    game = Fabricate(:game, parameter_hash: simulator.parameter_hash)
    SymmetricProfile.create!(simulator_id: simulator.id, parameter_hash: game.parameter_hash, size: game.size, proto_string: "A, A")
    GameAssociater.should have_queued(Profile.last.id)
    ResqueSpec.perform_all(:profile_actions)
    GameAssociater.should_not have_queued(Profile.last.id)
    Game.last.profiles.count.should == 1
    Game.last.profiles.first.should == Profile.last
  end
end