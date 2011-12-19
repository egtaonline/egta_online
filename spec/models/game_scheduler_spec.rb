require 'spec_helper'

describe GameScheduler do
  before do
    ResqueSpec.reset!
  end
  describe "#destroy" do
    let!(:simulator){Fabricate(:simulator)}
    let!(:profile){Fabricate(:profile, :simulator_id => simulator.id)}
    let!(:game_scheduler){Fabricate(:game_scheduler, :simulator_id => simulator.id)}
    it "should preserve profiles" do
      game_scheduler.profile_ids << profile.id
      game_scheduler.save!
      GameScheduler.first.destroy
      Profile.count.should == 1
    end
  end
  describe "#remove_strategy" do
    let!(:simulator){Fabricate(:simulator)}
    let!(:game_scheduler){Fabricate(:game_scheduler, :simulator_id => simulator.id, :parameter_hash => simulator.parameter_hash)}
    it "should preserve profiles" do
      game_scheduler.add_role("All", 2)
      game_scheduler.add_strategy("All", "A")
      ResqueSpec.perform_all(:profile_actions)
      game_scheduler = GameScheduler.first
      game_scheduler.profile_ids.size.should == 1
      game_scheduler.remove_strategy("All", "A")
      GameScheduler.first.profile_ids.size.should == 0
      Profile.count.should == 1
    end
  end
end