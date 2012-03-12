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
end