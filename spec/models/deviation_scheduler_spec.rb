require 'spec_helper'

describe DeviationScheduler do
  describe "#add_role" do
    let!(:scheduler){Fabricate(:deviation_scheduler)}
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
    let!(:scheduler){Fabricate(:deviation_scheduler)}
    before(:each) {scheduler.add_role("Bidder", 2)}
    it "should remove the role from both roles and deviating roles" do
      scheduler.remove_role("Bidder")
      scheduler.roles.count.should eql(0)
      scheduler.deviating_roles.count.should eql(0)
    end
  end
  
  describe "#add_deviating_strategy" do
    let!(:scheduler){Fabricate(:deviation_scheduler)}
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
  end
  
  describe "#remove_deviating_strategy" do
    let!(:scheduler){Fabricate(:deviation_scheduler)}
    let!(:strategy1){Fabricate(:strategy, :number => 1)}
    before(:each) do
      scheduler.add_role("All", scheduler.size)
      scheduler.add_deviating_strategy("All", strategy1.name)
    end
    it "should remove the strategy from the deviating role" do
      scheduler.remove_deviating_strategy("All", strategy1.name)
      scheduler.deviating_roles.where(:name => "All").first.strategies.count.should eql(0)
    end
  end
  
  describe "#unused_strategies" do
    let!(:scheduler){Fabricate(:deviation_scheduler)}
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