require 'spec_helper'

describe "#find_games" do
  before do
    ResqueSpec.reset!
  end

  it "should associate a profile to a game" do
    game = Fabricate(:game)
    Profile.create!(simulator_id: game.simulator.id, parameter_hash: game.parameter_hash, name: "All: 2 A")
    GameAssociater.should have_queued(Profile.last.id)
    ResqueSpec.perform_all(:profile_actions)
    GameAssociater.should_not have_queued(Profile.last.id)
    Game.last.profile_ids.count.should == 1
    Game.last.profile_ids.first.should == Profile.last.id
  end
end