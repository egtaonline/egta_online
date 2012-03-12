require 'spec_helper'

describe "HierarchicalSchedulers" do

  describe "GET /hierarchical_schedulers" do
    it "should show only hierarchical schedulers" do
      s1 = Fabricate(:scheduler)
      s2 = Fabricate(:hierarchical_scheduler)
      visit hierarchical_schedulers_path
      page.should have_content("Hierarchical Schedulers")
      page.should_not have_content(s1.name)
      page.should have_content(s2.name)
    end
  end

  describe "POST /hierarchical_schedulers" do
    it "creates a hierarchical scheduler" do
      Fabricate(:simulator)
      visit new_hierarchical_scheduler_path
      fill_in "Name", :with => "Test1"
      fill_in "Full game size", :with => "4"
      fill_in "Agents per player", :with => "2"
      fill_in "Max samples", :with => "30"
      fill_in "Samples per simulation", :with => "15"
      fill_in "Process memory", :with => "1000"
      fill_in "Time per sample", :with => "40"
      click_button "Create Hierarchical scheduler"
      page.should_not have_content("Some errors were found")
      page.should have_content("Test1")
      page.should have_content("30")
      page.should have_content("15")
      page.should have_content("1000")
      page.should have_content("40")
      page.should have_content("Inspect Hierarchical Scheduler")
    end
  end

  describe "POST /hierarchical_schedulers/:id/add_role" do
    it "should add the required role" do
      hierarchical_scheduler = Fabricate(:hierarchical_scheduler)
      Simulator.last.add_role("All")
      visit hierarchical_scheduler_path(hierarchical_scheduler.id)
      click_button "Add Role"
      page.should have_content("Inspect Hierarchical Scheduler")
      page.should have_content("All")
      page.should_not have_content("Some errors were found")
      HierarchicalScheduler.last.roles.count.should eql(1)
    end
  end
  
  describe "POST /hierarchical_schedulers/:id/remove_role" do
    it "removes the relevant role" do
      hierarchical_scheduler = Fabricate(:hierarchical_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      hierarchical_scheduler.add_role("Bidder", hierarchical_scheduler.size)
      visit hierarchical_scheduler_path(hierarchical_scheduler.id)
      HierarchicalScheduler.last.roles.count.should eql(1)
      click_on "Remove Role"
      page.should have_content("Inspect Hierarchical Scheduler")
      page.should_not have_content("Some errors were found")
      HierarchicalScheduler.last.roles.count.should eql(0)
    end
  end

  describe "POST /hierarchical_schedulers/:id/add_strategy" do
    it "adds the relevant strategy" do
      hierarchical_scheduler = Fabricate(:hierarchical_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      hierarchical_scheduler.add_role("Bidder", hierarchical_scheduler.size)
      visit hierarchical_scheduler_path(hierarchical_scheduler.id)
      click_button "Add Strategy"
      page.should have_content("Inspect Hierarchical Scheduler")
      page.should have_content("Strat1")
      page.should_not have_content("Some errors were found")
      HierarchicalScheduler.last.roles.last.strategies.count.should eql(1)
      HierarchicalScheduler.last.roles.last.strategies.last.name.should eql("Strat1")
    end
  end
  
  describe "POST /hierarchical_schedulers/:id/remove_strategy" do
    it "adds the relevant strategy" do
      hierarchical_scheduler = Fabricate(:hierarchical_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      hierarchical_scheduler.add_role("Bidder", hierarchical_scheduler.size)
      hierarchical_scheduler.add_strategy("Bidder", "Strat1")
      visit hierarchical_scheduler_path(hierarchical_scheduler.id)
      click_on "Remove Strategy"
      page.should have_content("Inspect Hierarchical Scheduler")
      page.should_not have_content("Some errors were found")
      HierarchicalScheduler.last.roles.last.strategies.count.should eql(0)
    end
  end
end