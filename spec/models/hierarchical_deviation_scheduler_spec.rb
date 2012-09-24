require 'spec_helper'

describe HierarchicalDeviationScheduler do
  before do
    ResqueSpec.reset!
  end

  describe "#unassigned_player_count" do
    let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, :size => 4) }
    before(:each) do
      scheduler.add_role("Bidder", 1)
    end
    it {scheduler.unassigned_player_count.should eql(3)}
  end

  describe "#add_deviating_strategy" do
    context "symmetric" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler)}
      before(:each) do
        scheduler.add_role("All", 2)
        scheduler.add_deviating_strategy("All", "A")
      end
      it "should not lead to profile creation if there are no strategies on the target roles" do
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(0)
      end
      it "should lead to profile creation if there are strategies on the target role" do
        scheduler.add_strategy("All", "B")
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(2)
        Profile.with_scheduler(scheduler).collect{|p| p.assignment}.should eql(["All: 120 B", "All: 60 A, 60 B"])
      end
    end

    context "role-symmetric" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 40)}
      it "should create the correct set of profiles" do
        scheduler.add_role("Bidder", 2)
        scheduler.add_role("Seller", 1)
        scheduler.add_strategy("Bidder", "A")
        scheduler.add_strategy("Bidder", "B")
        scheduler.add_deviating_strategy("Bidder", "C")
        scheduler.add_strategy("Seller", "D")
        scheduler.add_deviating_strategy("Seller", "B")
        scheduler.add_deviating_strategy("Seller", "C")
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(11)
        ret = ["Bidder: 80 A; Seller: 40 D",
               "Bidder: 40 A, 40 B; Seller: 40 D",
               "Bidder: 80 B; Seller: 40 D",
               "Bidder: 40 A, 40 C; Seller: 40 D",
               "Bidder: 40 B, 40 C; Seller: 40 D",
               "Bidder: 80 A; Seller: 40 B",
               "Bidder: 40 A, 40 B; Seller: 40 B",
               "Bidder: 80 B; Seller: 40 B",
               "Bidder: 80 A; Seller: 40 C",
               "Bidder: 40 A, 40 B; Seller: 40 C",
               "Bidder: 80 B; Seller: 40 C"]
        Profile.with_scheduler(scheduler).collect{|p| p.assignment}.sort.should eql(ret.sort)
      end
    end
  end

  describe "#remove_deviating_strategy" do
    let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 40)}
    it "should remove the relevant profiles from the scheduler, but not from the system" do
      scheduler.add_role("Bidder", 2)
      scheduler.add_role("Seller", 1)
      scheduler.add_strategy("Bidder", "A")
      scheduler.add_strategy("Bidder", "B")
      scheduler.add_deviating_strategy("Bidder", "C")
      scheduler.add_strategy("Seller", "D")
      scheduler.add_deviating_strategy("Seller", "B")
      scheduler.add_deviating_strategy("Seller", "C")
      ResqueSpec.perform_all(:profile_actions)
      scheduler.remove_deviating_strategy("Seller", "C")
      ResqueSpec.perform_all(:profile_actions)
      scheduler.reload
      Profile.with_scheduler(scheduler).count.should eql(8)
      Profile.count.should eql(11)
    end
  end
end