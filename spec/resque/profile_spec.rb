require 'spec_helper'

describe "#find_games" do
  let!(:game){ Fabricate(:game) }
  let!(:profile){ Fabricate(:profile, simulator: game.simulator, configuration: game.configuration, assignment: 'All: 2 A') }
  
  before do
    ResqueSpec.perform_all(:profile_actions)
    game.reload
    profile.reload
  end

  it { game.profile_ids.count.should eql(1) }
  it { game.profile_ids.first.should eql(profile.id) }
end