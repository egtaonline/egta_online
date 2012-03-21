require 'spec_helper'

describe "DeviationSchedulers" do
  before do
    ResqueSpec.reset!
  end
  
  shared_examples "a deviation scheduler" do
    describe "#add_role" do
      before(:each) {scheduler.add_role("Bidder", 2)}
      it "should add a role to both roles and deviating roles" do
        scheduler.roles.count.should eql(1)
        scheduler.deviating_roles.count.should eql(1)
      end
      it "should not add the same role to each" do
        scheduler.roles.first.should_not eql(scheduler.deviating_roles.first)
      end
    end
  
    describe "#remove_role" do
      before(:each) {scheduler.add_role("Bidder", 2)}
      it "should remove the role from both roles and deviating roles" do
        scheduler.remove_role("Bidder")
        scheduler.roles.count.should eql(0)
        scheduler.deviating_roles.count.should eql(0)
      end
    end
  
    describe "#add_deviating_strategy" do
      context "symmetric" do
        let!(:strategy1){Fabricate(:strategy, :number => 1)}
        before(:each) do
          scheduler.add_role("All", scheduler.size)
          scheduler.add_deviating_strategy("All", strategy1.name)
        end
        it "should add the strategy to the appropriate deviating role" do
          scheduler.deviating_roles.where(:name => "All").first.strategies.first.should eql(strategy1)
        end
        it "should not add the strategy to a non-deviating role" do
          scheduler.roles.where(:name => "All").first.strategies.count.should eql(0)
        end
        it "should not lead to profile creation if there are no strategies on the target roles" do
          ResqueSpec.perform_all(:profile_actions)
          Profile.count.should eql(0)
        end
        it "should lead to profile creation if there are strategies on the target role" do
          strategy2 = Fabricate(:strategy, :number => 2)
          scheduler.add_strategy("All", strategy2.name)
          ResqueSpec.perform_all(:profile_actions)
          Profile.count.should eql(2)
          scheduler.reload.profiles.collect{|p| p.name}.should eql(["All: 2 #{strategy2.name}", "All: 1 #{strategy1.name}, 1 #{strategy2.name}"])
        end
      end
    
      context "role-symmetric" do
        let!(:strategy1){Fabricate(:strategy, :number => 1)}
        let!(:strategy2){Fabricate(:strategy, :number => 2)}
        let!(:strategy3){Fabricate(:strategy, :number => 3)}
        let!(:strategy4){Fabricate(:strategy, :number => 4)}
        it "should create the correct set of profiles" do
          scheduler3.add_role("Bidder", 2)
          scheduler3.add_role("Seller", 1)
          scheduler3.add_strategy("Bidder", strategy1.name)
          scheduler3.add_strategy("Bidder", strategy2.name)
          scheduler3.add_deviating_strategy("Bidder", strategy3.name)
          scheduler3.add_strategy("Seller", strategy4.name)
          scheduler3.add_deviating_strategy("Seller", strategy2.name)
          scheduler3.add_deviating_strategy("Seller", strategy3.name)
          ResqueSpec.perform_all(:profile_actions)
          Profile.count.should eql(11)
          ret = ["Bidder: 2 #{strategy1.name}; Seller: 1 #{strategy4.name}",
                 "Bidder: 1 #{strategy1.name}, 1 #{strategy2.name}; Seller: 1 #{strategy4.name}",
                 "Bidder: 2 #{strategy2.name}; Seller: 1 #{strategy4.name}",
                 "Bidder: 1 #{strategy1.name}, 1 #{strategy3.name}; Seller: 1 #{strategy4.name}",
                 "Bidder: 1 #{strategy2.name}, 1 #{strategy3.name}; Seller: 1 #{strategy4.name}",
                 "Bidder: 2 #{strategy1.name}; Seller: 1 #{strategy2.name}",
                 "Bidder: 1 #{strategy1.name}, 1 #{strategy2.name}; Seller: 1 #{strategy2.name}",
                 "Bidder: 2 #{strategy2.name}; Seller: 1 #{strategy2.name}",
                 "Bidder: 2 #{strategy1.name}; Seller: 1 #{strategy3.name}",
                 "Bidder: 1 #{strategy1.name}, 1 #{strategy2.name}; Seller: 1 #{strategy3.name}",
                 "Bidder: 2 #{strategy2.name}; Seller: 1 #{strategy3.name}"]
          scheduler3.reload.profiles.collect{|p| p.name}.should eql(ret)
        end
      end
    end
  
    describe "#remove_deviating_strategy" do
      let!(:strategy1){Fabricate(:strategy, :number => 1)}
      let!(:strategy2){Fabricate(:strategy, :number => 2)}
      let!(:strategy3){Fabricate(:strategy, :number => 3)}
      let!(:strategy4){Fabricate(:strategy, :number => 4)}
      it "should remove the strategy from the deviating role" do
        scheduler.add_role("All", scheduler.size)
        scheduler.add_deviating_strategy("All", strategy1.name)
        scheduler.remove_deviating_strategy("All", strategy1.name)
        scheduler.deviating_roles.where(:name => "All").first.strategies.count.should eql(0)
      end
      it "should remove the relevant profiles from the scheduler, but not from the system" do
        scheduler3.add_role("Bidder", 2)
        scheduler3.add_role("Seller", 1)
        scheduler3.add_strategy("Bidder", strategy1.name)
        scheduler3.add_strategy("Bidder", strategy2.name)
        scheduler3.add_deviating_strategy("Bidder", strategy3.name)
        scheduler3.add_strategy("Seller", strategy4.name)
        scheduler3.add_deviating_strategy("Seller", strategy2.name)
        scheduler3.add_deviating_strategy("Seller", strategy3.name)
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(11)
        scheduler3.reload
        scheduler3.remove_deviating_strategy("Seller", strategy3.name)
        scheduler3.profiles.count.should eql(8)
        Profile.count.should eql(11)
      end
    end
  
    describe "#unused_strategies" do
      let!(:strategy1){Fabricate(:strategy, :number => 1)}
      let!(:strategy2){Fabricate(:strategy, :number => 2)}
      let!(:strategy3){Fabricate(:strategy, :number => 3)}
      before(:each) do
        scheduler.simulator.add_strategy("All", strategy1.name)
        scheduler.simulator.add_strategy("All", strategy2.name)
        scheduler.simulator.add_strategy("All", strategy3.name)
        scheduler.add_role("All", scheduler.size)
      end
      it "should show only strategies assigned to neither group" do
        role = scheduler.roles.where(:name => "All").first
        scheduler.unused_strategies(role).count.should eql(3)
        scheduler.add_strategy("All", strategy1.name)
        scheduler.unused_strategies(role).count.should eql(2)
        scheduler.add_deviating_strategy("All", strategy2.name)
        scheduler.unused_strategies(role).count.should eql(1)
      end
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a deviation scheduler" do
      let!(:scheduler){Fabricate(:deviation_scheduler)}
      let!(:scheduler3){Fabricate(:deviation_scheduler, :size => 3)}
    end
  end
  
  describe HierarchicalDeviationScheduler do
    it_behaves_like "a deviation scheduler" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 1, :size => 2)}
      let!(:scheduler3){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 1, :size => 3)}
    end
  end
end