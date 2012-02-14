require 'spec_helper'

describe "Games" do
  before(:each) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "GET /games" do
    it "displays games" do
      game = Fabricate(:game)
      visit games_path
      page.should have_content(game.name)
      page.should have_content(game.simulator.fullname)
      page.should have_content(game.size)
    end
  end
  
  describe "GET /games/:id" do
    it "displays the relevant game" do
      game = Fabricate(:game)
      visit game_path(game.id)
      page.should have_content(game.name)
      page.should have_content(game.simulator.fullname)
      page.should have_content(game.size)
    end
  end
  
  describe "POST /games" do
    before(:each) do
      ResqueSpec.reset!
    end
    
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
end