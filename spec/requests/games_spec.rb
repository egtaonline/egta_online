require 'spec_helper'

describe "Games" do

  describe "GET /games" do
    it "displays games" do
      game = Fabricate(:game)
      visit games_path
      page.should have_content(game.name)
      page.should have_content(game.simulator_fullname)
      page.should have_content(game.size)
    end
  end

  describe "GET /games/:id" do
    it "displays the relevant game" do
      game = Fabricate(:game)
      visit game_path(game.id)
      page.should have_content(game.name)
      page.should have_content(game.simulator_fullname)
      page.should have_content(game.size)
    end
  end

  describe "GET /games/new" do
    it "should render the new game form" do
      visit new_game_path
      page.should have_content("New Game")
      page.should have_content("Name")
      page.should have_content("Game size")
    end
  end

  context "GET /games/:id/edit" do
    it "should show the edit page for the game" do
      game = Fabricate(:game)
      visit edit_game_path(game.id)
      page.should have_content("Edit Game")
      page.should have_content("Name")
    end
  end

  context "PUT /games/:id" do
    it "should update the relevant game" do
      game = Fabricate(:game)
      visit edit_game_path(game.id)
      fill_in "Name", :with => "UpdatedName"
      click_button "Update Game"
      page.should have_content("Inspect Game")
      page.should have_content("UpdatedName")
    end
  end

  describe "POST /games" do
    it "creates a game" do
      Fabricate(:simulator)
      visit new_game_path
      fill_in "Name", :with => "epp_sim"
      fill_in "Game size", :with => "2"
      click_button "Create Game"
      page.should have_content("epp_sim")
      page.should have_content("2")
      page.should have_content(Simulator.last.fullname)
      page.should_not have_content("Some errors were found")
    end
  end

  describe "DELETE /games/:id/" do
    it "destroys the relevant game" do
      game = Fabricate(:game)
      visit games_path
      click_on "Destroy"
      Game.count.should eql(0)
    end
  end

  describe "POST /games/:id/add_role" do
    it "should add the required role" do
      game = Fabricate(:game)
      Simulator.last.add_role("All")
      visit game_path(game.id)
      click_button "Add Role"
      page.should have_content("Inspect Game")
      page.should have_content("All")
      page.should_not have_content("Some errors were found")
      Game.last.roles.count.should eql(1)
    end
  end

  describe "POST /games/:id/remove_role" do
    it "removes the relevant role" do
      game = Fabricate(:game)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game.add_role("Bidder", game.size)
      visit game_path(game.id)
      Game.last.roles.count.should eql(1)
      click_on "Remove Role"
      page.should have_content("Inspect Game")
      page.should_not have_content("Some errors were found")
      Game.last.roles.count.should eql(0)
    end
  end

  describe "POST /games/:id/add_strategy" do
    it "adds the relevant strategy" do
      game = Fabricate(:game)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game.add_role("Bidder", game.size)
      visit game_path(game.id)
      click_button "Add Strategy"
      page.should have_content("Inspect Game")
      page.should have_content("Strat1")
      page.should_not have_content("Some errors were found")
      Game.last.roles.last.strategies.count.should eql(1)
      Game.last.roles.last.strategies.last.should eql("Strat1")
    end
  end

  describe "POST /games/:id/remove_strategy" do
    it "adds the relevant strategy" do
      game = Fabricate(:game)
      Simulator.last.add_strategy("Bidder", "Strat1")
      game.add_role("Bidder", game.size)
      game.add_strategy("Bidder", "Strat1")
      visit game_path(game.id)
      click_on "Remove Strategy"
      page.should have_content("Inspect Game")
      page.should_not have_content("Some errors were found")
      Game.last.roles.last.strategies.count.should eql(0)
    end
  end

  describe "POST /games/update_configuration", :js => true do
    it "should update parameter info" do
      sim1 = Fabricate(:simulator, :configuration => {"Parm1"=>"2","Parm2"=>"3"})
      sim2 = Fabricate(:simulator, :configuration => {"Parm2"=>"7","Parm3"=>"6"})
      visit new_game_path
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