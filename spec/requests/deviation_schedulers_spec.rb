require 'spec_helper'

describe "DeviationSchedulers" do
  context "POST /game_schedulers" do
    it "creates a deviation scheduler" do
      Fabricate(:simulator)
      visit new_deviation_scheduler_path
      fill_in "Name", :with => "Test1"
      fill_in "Game size", :with => "2"
      fill_in "Max samples", :with => "30"
      fill_in "Samples per simulation", :with => "15"
      fill_in "Process memory", :with => "1000"
      fill_in "Time per sample", :with => "40"
      click_button "Create Deviation scheduler"
      page.should_not have_content("Some errors were found")
      page.should have_content("Test1")
      page.should have_content("30")
      page.should have_content("15")
      page.should have_content("1000")
      page.should have_content("40")
      page.should have_content("Inspect Deviation Scheduler")
    end
  end
end