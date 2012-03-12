require 'spec_helper'

describe "game_scheduler" do

  context "GET /game_schedulers" do
    it "should shows only game schedulers" do
      s1 = Fabricate(:scheduler)
      s2 = Fabricate(:game_scheduler)
      visit game_schedulers_path
      page.should have_content("Game Schedulers")
      page.should_not have_content(s1.name)
      page.should have_content(s2.name)
    end
  end

  describe "POST /game_schedulers" do
    it "creates a game scheduler" do
      Fabricate(:simulator)
      visit new_game_scheduler_path
      fill_in "Name", :with => "Test1"
      fill_in "Game size", :with => "2"
      fill_in "Max samples", :with => "30"
      fill_in "Samples per simulation", :with => "15"
      fill_in "Process memory", :with => "1000"
      fill_in "Time per sample", :with => "40"
      click_button "Create Game scheduler"
      page.should_not have_content("Some errors were found")
      page.should have_content("Test1")
      page.should have_content("30")
      page.should have_content("15")
      page.should have_content("1000")
      page.should have_content("40")
      page.should have_content("Inspect Game Scheduler")
    end
  end

  describe "POST /game_schedulers/:id/add_role" do
    it "should add the required role" do
      game_scheduler = Fabricate(:game_scheduler)
      Simulator.last.add_role("All")
      visit game_scheduler_path(game_scheduler.id)
      click_button "Add Role"
      page.should have_content("Inspect Game Scheduler")
      page.should have_content("All")
      page.should_not have_content("Some errors were found")
      GameScheduler.last.roles.count.should eql(1)
    end
  end
  
  describe "POST /game_schedulers/:id/remove_role" do
    it "removes the relevant role" do
      game_scheduler = Fabricate(:game_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game_scheduler.add_role("Bidder", game_scheduler.size)
      visit game_scheduler_path(game_scheduler.id)
      GameScheduler.last.roles.count.should eql(1)
      click_on "Remove Role"
      page.should have_content("Inspect Game Scheduler")
      page.should_not have_content("Some errors were found")
      GameScheduler.last.roles.count.should eql(0)
    end
  end

  describe "POST /game_schedulers/:id/add_strategy" do
    it "adds the relevant strategy" do
      game_scheduler = Fabricate(:game_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game_scheduler.add_role("Bidder", game_scheduler.size)
      visit game_scheduler_path(game_scheduler.id)
      click_button "Add Strategy"
      page.should have_content("Inspect Game Scheduler")
      page.should have_content("Strat1")
      page.should_not have_content("Some errors were found")
      GameScheduler.last.roles.last.strategies.count.should eql(1)
      GameScheduler.last.roles.last.strategies.last.name.should eql("Strat1")
    end
  end
  
  describe "POST /game_schedulers/:id/remove_strategy" do
    it "adds the relevant strategy" do
      game_scheduler = Fabricate(:game_scheduler)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game_scheduler.add_role("Bidder", game_scheduler.size)
      game_scheduler.add_strategy("Bidder", "Strat1")
      visit game_scheduler_path(game_scheduler.id)
      click_on "Remove Strategy"
      page.should have_content("Inspect Game Scheduler")
      page.should_not have_content("Some errors were found")
      GameScheduler.last.roles.last.strategies.count.should eql(0)
    end
  end
  
  describe "POST /game_schedulers/update_parameters", :js => true do
    it "should update parameter info" do
      sim1 = Fabricate(:simulator, :parameter_hash => {"Parm1"=>"2","Parm2"=>"3"})
      sim2 = Fabricate(:simulator, :parameter_hash => {"Parm2"=>"7","Parm3"=>"6"})
      visit new_game_scheduler_path
      page.should have_content("Parm1")
      page.should have_content("Parm2")
      page.should_not have_content("Parm3")
      select sim2.fullname, :from => :simulator_id
      page.should_not have_content("Parm1")
      page.should have_content("Parm2")
      page.should have_content("Parm3")
    end
  end
end