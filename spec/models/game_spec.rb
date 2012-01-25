require 'spec_helper'

describe Game do
  describe "#destroy" do
    let!(:game){Fabricate(:game)}
    let!(:strategy){Fabricate(:strategy, :name => "A")}
    let!(:profile){Fabricate(:profile, :simulator_id => game.simulator.id)}
    it "should preserve profiles" do
      game.profile_ids << profile.id
      game.save!
      Game.first.destroy
      Profile.count.should == 1
    end
  end
end