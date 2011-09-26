require 'spec_helper'

describe "#testing updates" do
  before do
    ResqueSpec.reset!
  end

  let!(:simulator){Fabricate(:simulator)}
  let!(:scheduler){Fabricate(:game_scheduler, simulator_id: simulator.id, active: false, parameter_hash: simulator.parameter_hash)}
  it "should try to schedule profile on activation" do
    simulator.roles.create!(name: "All")
    Account.create(username: "bcassell", active: true)
    scheduler.roles.create!(name: "All", count: 2)
    scheduler.add_strategy_by_name("All", "A")
    ResqueSpec.perform_all(:profile_actions)
    scheduler = Scheduler.last
    scheduler.update_attribute(:active, true)
    ProfileScheduler.should have_queued(Profile.last.id)
    ResqueSpec.perform_all(:profile_actions)
    Simulation.count.should == 1
    scheduler.update_attribute(:parameter_hash, {a: 3})
    ProfileAssociater.should have_queued(scheduler.id)
    ResqueSpec.perform_all(:profile_actions)
    Simulation.count.should == 2
    Profile.count.should == 2
    Scheduler.last.profile_ids.count.should == 1
  end
end