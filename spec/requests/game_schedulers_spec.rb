require 'spec_helper'

describe "GameSchedulers" do
  shared_examples "a game scheduler on requests" do
    context "POST /#{described_class.to_s.tableize}/:id/add_role" do
      it "should add the required role" do
        Simulator.last.add_role("All123")
        visit "/#{described_class.to_s.tableize}/#{game_scheduler.id}"
        click_button "Add Role"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should have_content("All123")
        page.should_not have_content("Some errors were found")
        described_class.last.roles.count.should eql(1)
      end
    end
    
    context "POST /#{described_class.to_s.tableize}/:id/remove_role" do
      it "removes the relevant role" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", 1)
        visit "/#{described_class.to_s.tableize}/#{game_scheduler.id}"
        described_class.last.roles.count.should eql(1)
        click_on "Remove Role"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should_not have_content("Some errors were found")
        described_class.last.roles.count.should eql(0)
      end
    end
    
    describe "POST /#{described_class.to_s.tableize}/:id/add_strategy" do
      it "adds the relevant strategy" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", game_scheduler.size)
        visit "/#{described_class.to_s.tableize}/#{game_scheduler.id}"
        click_button "Add Strategy"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should have_content("Strat1")
        page.should_not have_content("Some errors were found")
        described_class.last.roles.last.strategies.count.should eql(1)
        described_class.last.roles.last.strategies.last.name.should eql("Strat1")
      end
    end

    describe "POST /#{described_class.to_s.tableize}/:id/remove_strategy" do
      it "removes the relevant strategy" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", 1)
        game_scheduler.add_strategy("Bidder", "Strat1")
        visit "/#{described_class.to_s.tableize}/#{game_scheduler.id}"
        click_on "Remove Strategy"
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should_not have_content("Some errors were found")
        described_class.last.roles.last.strategies.count.should eql(0)
      end
    end
  end

  describe GameScheduler do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){Fabricate(:game_scheduler)}
    end
  end

  describe HierarchicalScheduler do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){Fabricate(:hierarchical_scheduler)}
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){Fabricate(:deviation_scheduler)}
    end
  end

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
end