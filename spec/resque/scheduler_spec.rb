require 'spec_helper'

describe "#testing updates" do
  before do
    ResqueSpec.reset!
    Account.new(username: "bcassell", active: true).save(:validate => false)
  end

  let!(:simulator){Fabricate(:simulator)}
  let!(:scheduler){Fabricate(:game_scheduler, simulator: simulator, active: false, configuration: simulator.configuration)}
  it "should try to schedule profile on activation" do
    simulator.roles.create!(name: "All")
    Account.create(username: "bcassell", active: true)
    scheduler.roles.create!(name: "All", count: 2)
    scheduler.add_strategy("All", "A")
    ResqueSpec.perform_all(:profile_actions)
    scheduler = Scheduler.last
    scheduler.update_attribute(:active, true)
    ProfileScheduler.should have_queued(Profile.last.id)
    ResqueSpec.perform_all(:profile_actions)
    Simulation.count.should == 1
    scheduler.update_attribute(:configuration, {a: 3})
    ProfileAssociater.should have_queued(scheduler.id)
    ResqueSpec.perform_all(:profile_actions)
    ProfileScheduler.should have_scheduled(Profile.last.id).in(5 * 60)
    Simulation.count.should == 1
    Profile.count.should == 2
    Scheduler.last.profile_ids.count.should == 1
  end
end