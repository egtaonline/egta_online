require 'spec_helper'

describe GenericScheduler do
  describe "#required_samples" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, simulator: scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, assignment: 'All: 1 A, 1 B', simulator: scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, assignment: 'All: 2 B', simulator: scheduler.simulator)}
    before do
      scheduler.add_profile(profile.assignment, 30)
      scheduler.add_profile(profile.assignment, 20)
      scheduler.add_profile(profile1.assignment, 10)
    end
    it {scheduler.required_samples(profile).should eql(20)}
    it {scheduler.required_samples(profile1).should eql(10)}
    it {scheduler.required_samples(profile2).should eql(0)}
  end

  describe "#remove_role" do
    let!(:scheduler){ Fabricate(:generic_scheduler) }
    let!(:profile){ Fabricate(:profile, simulator: scheduler.simulator) }
    let!(:profile1){ Fabricate(:profile, assignment: 'Bidder: 1 A; Seller: 1 B', simulator: scheduler.simulator) }

    context "local" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.assignment, 30)
        scheduler.add_profile(profile1.assignment, 20)
        scheduler.remove_role("All")
        scheduler.reload
      end

      it { Profile.with_scheduler(scheduler).count.should eql(1) }
      it { Profile.with_scheduler(scheduler).last.assignment.should eql(profile1.assignment) }
      it { scheduler.required_samples(profile1).should eql(20) }
      it { scheduler.required_samples(profile).should eql(0)}
    end

    context "simulator" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.assignment, 30)
        scheduler.add_profile(profile1.assignment, 20)
        simulator.remove_role("All")
      end

      it { Profile.with_scheduler(scheduler).count.should eql(1) }
      it { Profile.with_scheduler(scheduler).last.assignment.should eql(profile1.assignment) }
      it { scheduler.required_samples(profile1).should eql(20) }
      it { scheduler.required_samples(profile).should eql(0)}
    end
  end

  describe "#remove_strategy" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :assignment => "Bidder: 1 A; Seller: 1 B", :simulator => scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, :assignment => "All: 2 B", :simulator => scheduler.simulator)}

    context "local" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.assignment, 30)
        scheduler.add_profile(profile1.assignment, 20)
        scheduler.add_profile(profile2.assignment, 20)
        scheduler.remove_strategy("All", "A")
      end

      it { Profile.with_scheduler(scheduler).count.should eql(2) }
      it { Profile.with_scheduler(scheduler).last.assignment.should eql(profile2.assignment) }
      it { scheduler.required_samples(profile2).should eql(20) }
      it { scheduler.required_samples(profile).should eql(0) }
    end

    context "simulator" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.assignment, 30)
        scheduler.add_profile(profile1.assignment, 20)
        scheduler.add_profile(profile2.assignment, 20)
        simulator.remove_strategy("All", "A")
      end

      it { Profile.with_scheduler(scheduler).count.should eql(2) }
      it { Profile.with_scheduler(scheduler).last.assignment.should eql(profile2.assignment) }
      it { scheduler.required_samples(profile2).should eql(20) }
      it { scheduler.required_samples(profile).should eql(0)}
    end
  end
end