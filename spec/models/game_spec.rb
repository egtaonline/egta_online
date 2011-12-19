require 'spec_helper'

describe Game do
  describe "#destroy" do
    let!(:simulator){Fabricate(:simulator)}
    let!(:profile){Fabricate(:profile, :simulator_id => simulator.id)}
    let!(:game){Fabricate(:game, :simulator_id => simulator.id)}
    it "should preserve profiles" do
      game.profile_ids << profile.id
      game.save!
      Game.first.destroy
      Profile.count.should == 1
    end
  end
end