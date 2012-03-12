require 'spec_helper'

describe "SubgameDeviationSchedulers" do
  describe "POST /subgame_deviation_schedulers/update_parameters", :js => true do
    it "should update parameter info" do
      sim1 = Fabricate(:simulator, :parameter_hash => {"Parm1"=>"2","Parm2"=>"3"})
      sim2 = Fabricate(:simulator, :parameter_hash => {"Parm2"=>"7","Parm3"=>"6"})
      visit new_subgame_deviation_scheduler_path
      page.should have_content("Parm1")
      page.should have_content("Parm2")
      page.should_not have_content("Parm3")
      select sim2.fullname, :from => :simulator_id
      page.should_not have_content("Parm1")
      page.should have_content("Parm2")
      page.should have_content("Parm3")
    end
  end
  # 
  # describe "GET /schedulers" do
  #   it "should show all schedulers" do
  #     s1 = Fabricate(:scheduler)
  #     s2 = Fabricate(:game_scheduler)
  #     visit schedulers_path
  #     page.should have_content("Schedulers")
  #     page.should have_content(s1.name)
  #     page.should have_content(s2.name)
  #   end
  # end
  # 
  # describe "POST /schedulers" do
  #   it "creates a scheduler" do
  #     Fabricate(:simulator)
  #     visit new_scheduler_path
  #     fill_in "Name", :with => "Test1"
  #     fill_in "Max samples", :with => "30"
  #     fill_in "Samples per simulation", :with => "15"
  #     fill_in "Process memory", :with => "1000"
  #     fill_in "Time per sample", :with => "40"
  #     click_button "Create Scheduler"
  #     page.should_not have_content("Some errors were found")
  #     page.should have_content("Test1")
  #     page.should have_content("30")
  #     page.should have_content("15")
  #     page.should have_content("1000")
  #     page.should have_content("40")
  #     page.should have_content("Inspect Scheduler")
  #   end
  # end
  # 
  # describe "GET /schedulers/new" do
  #   it "should show the new scheduler page" do
  #     Fabricate(:simulator)
  #     visit new_scheduler_path
  #     page.should have_content("New Scheduler")
  #     page.should have_content("Name")
  #   end
  # end
  # 
  # describe "GET /schedulers/:id/edit" do
  #   it "should show the edit page" do
  #     scheduler = Fabricate(:scheduler)
  #     visit edit_scheduler_path(scheduler.id)
  #     page.should have_content("Edit Scheduler")
  #     page.should have_content("Name")
  #   end
  # end
  # 
  # describe "GET /schedulers/:id" do
  #   it "should show the relevant scheduler" do
  #     scheduler = Fabricate(:scheduler)
  #     visit scheduler_path(scheduler.id)
  #     page.should have_content("Inspect Scheduler")
  #     page.should have_content(scheduler.name)
  #   end
  # end
  # 
  # describe "PUT /schedulers/:id" do
  #   it "should update the relevant scheduler" do
  #     scheduler = Fabricate(:scheduler)
  #     visit edit_scheduler_path(scheduler.id)
  #     fill_in "Max samples", :with => "100"
  #     click_button "Update Scheduler"
  #     page.should have_content("Inspect Scheduler")
  #     page.should have_content("100")
  #   end
  # end
  # 
  # describe "DELETE /schedulers/:id" do
  #   it "should delete the scheduler" do
  #     scheduler = Fabricate(:scheduler)
  #     visit schedulers_path
  #     click_on "Destroy"
  #     Scheduler.count.should eql(0)
  #   end
  # end
end