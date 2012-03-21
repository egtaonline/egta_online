require 'spec_helper'

describe HierarchicalDeviationScheduler do
  before do
    ResqueSpec.reset!
  end
  
  describe "#add_deviating_strategy" do
    context "symmetric" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler)}
      let!(:strategy1){Fabricate(:strategy, :number => 1)}
      before(:each) do
        scheduler.add_role("All", 2)
        scheduler.add_deviating_strategy("All", strategy1.name)
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
        scheduler.reload.profiles.collect{|p| p.name}.should eql(["All: 120 #{strategy2.name}", "All: 60 #{strategy1.name}, 60 #{strategy2.name}"])
      end
    end
    
    context "role-symmetric" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 40)}
      let!(:strategy1){Fabricate(:strategy, :number => 1)}
      let!(:strategy2){Fabricate(:strategy, :number => 2)}
      let!(:strategy3){Fabricate(:strategy, :number => 3)}
      let!(:strategy4){Fabricate(:strategy, :number => 4)}
      it "should create the correct set of profiles" do
        scheduler.add_role("Bidder", 2)
        scheduler.add_role("Seller", 1)
        scheduler.add_strategy("Bidder", strategy1.name)
        scheduler.add_strategy("Bidder", strategy2.name)
        scheduler.add_deviating_strategy("Bidder", strategy3.name)
        scheduler.add_strategy("Seller", strategy4.name)
        scheduler.add_deviating_strategy("Seller", strategy2.name)
        scheduler.add_deviating_strategy("Seller", strategy3.name)
        ResqueSpec.perform_all(:profile_actions)
        Profile.count.should eql(11)
        ret = ["Bidder: 80 #{strategy1.name}; Seller: 40 #{strategy4.name}",
               "Bidder: 40 #{strategy1.name}, 40 #{strategy2.name}; Seller: 40 #{strategy4.name}",
               "Bidder: 80 #{strategy2.name}; Seller: 40 #{strategy4.name}",
               "Bidder: 40 #{strategy1.name}, 40 #{strategy3.name}; Seller: 40 #{strategy4.name}",
               "Bidder: 40 #{strategy2.name}, 40 #{strategy3.name}; Seller: 40 #{strategy4.name}",
               "Bidder: 80 #{strategy1.name}; Seller: 40 #{strategy2.name}",
               "Bidder: 40 #{strategy1.name}, 40 #{strategy2.name}; Seller: 40 #{strategy2.name}",
               "Bidder: 80 #{strategy2.name}; Seller: 40 #{strategy2.name}",
               "Bidder: 80 #{strategy1.name}; Seller: 40 #{strategy3.name}",
               "Bidder: 40 #{strategy1.name}, 40 #{strategy2.name}; Seller: 40 #{strategy3.name}",
               "Bidder: 80 #{strategy2.name}; Seller: 40 #{strategy3.name}"]
        scheduler.reload.profiles.collect{|p| p.name}.should eql(ret)
      end
    end
  end
  
  describe "#remove_deviating_strategy" do
    let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, :agents_per_player => 40)}
    let!(:strategy1){Fabricate(:strategy, :number => 1)}
    let!(:strategy2){Fabricate(:strategy, :number => 2)}
    let!(:strategy3){Fabricate(:strategy, :number => 3)}
    let!(:strategy4){Fabricate(:strategy, :number => 4)}
    it "should remove the relevant profiles from the scheduler, but not from the system" do
      scheduler.add_role("Bidder", 2)
      scheduler.add_role("Seller", 1)
      scheduler.add_strategy("Bidder", strategy1.name)
      scheduler.add_strategy("Bidder", strategy2.name)
      scheduler.add_deviating_strategy("Bidder", strategy3.name)
      scheduler.add_strategy("Seller", strategy4.name)
      scheduler.add_deviating_strategy("Seller", strategy2.name)
      scheduler.add_deviating_strategy("Seller", strategy3.name)
      ResqueSpec.perform_all(:profile_actions)
      Profile.count.should eql(11)
      scheduler.reload
      scheduler.remove_deviating_strategy("Seller", strategy3.name)
      scheduler.profiles.count.should eql(8)
      Profile.count.should eql(11)
    end
  end
end