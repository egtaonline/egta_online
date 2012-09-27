require 'spec_helper'

describe HierarchicalDeviationScheduler do
  before do
    ResqueSpec.reset!
  end

  describe "#unassigned_player_count" do
    let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 4) }
    before(:each) do
      scheduler.add_role("Bidder", 1)
    end
    it {scheduler.unassigned_player_count.should eql(3)}
  end

  describe "#add_deviating_strategy" do
    context "symmetric" do
      let(:scheduler){Fabricate(:hierarchical_deviation_scheduler, size: 120)}
      before do
        scheduler.add_role("All", 120, 2)
        scheduler.add_deviating_strategy("All", "A")
      end
      # it "should not lead to profile creation if there are no strategies on the target roles" do
      #   ResqueSpec.perform_all(:profile_actions)
      #   Profile.count.should eql(0)
      # end
      it "should lead to profile creation if there are strategies on the target role" do
        scheduler.add_strategy("All", "B")
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(2)
        Profile.with_scheduler(scheduler).collect{|p| p.assignment}.should eql(["All: 120 B", "All: 60 A, 60 B"])
      end
    end

    context "role-symmetric" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler)}
      it "should create the correct set of profiles" do
        scheduler.add_role("Bidder", 80, 2)
        scheduler.add_role("Seller", 40, 1)
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

  describe '#profile_space' do
    context 'single role' do
      let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 5) }

      before do
        scheduler.add_role('All', 5, 2)
        scheduler.add_strategy('All', 'A')
        scheduler.add_strategy('All', 'B')
        scheduler.add_deviating_strategy('All', 'C')
      end

      it { scheduler.profile_space.sort.should eql(['All: 5 A', 'All: 3 A, 2 B', 'All: 3 A, 2 C', 'All: 5 B', 'All: 3 B, 2 C'].sort) }
    end

    context 'multiple roles' do
      let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 7) }

      before do
        scheduler.add_role('Role1', 3, 2)
        scheduler.add_role('Role2', 4, 2)
        scheduler.add_strategy('Role1', 'A')
        scheduler.add_strategy('Role1', 'B')
        scheduler.add_deviating_strategy('Role1', 'E')
        scheduler.add_strategy('Role2', 'C')
        scheduler.add_deviating_strategy('Role2', 'D')
      end

      it { scheduler.profile_space.sort.should eql(['Role1: 3 A; Role2: 4 C', 'Role1: 3 A; Role2: 2 C, 2 D', 'Role1: 2 A, 1 E; Role2: 4 C',
                                                    'Role1: 3 B; Role2: 4 C', 'Role1: 3 B; Role2: 2 C, 2 D', 'Role1: 2 B, 1 E; Role2: 4 C',
                                                    'Role1: 2 A, 1 B; Role2: 4 C', 'Role1: 2 A, 1 B; Role2: 2 C, 2 D'].sort) }
    end
  end

  describe "#remove_deviating_strategy" do
    let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler)}
    it "should remove the relevant profiles from the scheduler, but not from the system" do
      scheduler.add_role("Bidder", 80, 2)
      scheduler.add_role("Seller", 40, 1)
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