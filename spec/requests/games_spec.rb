require 'spec_helper'

describe "Games" do
  before(:each) do
    @user = User.make!
    @simulator = Simulator.make!
    visit "/"
    fill_in "Email", :with => "test@test.com"
    fill_in "Password", :with => "stuff1"
    check "Remember me"
    click_button "Sign in"
    @simulator2 = Simulator.make!(:parameters => "---\nweb parameters:\n    number of agents: 101")
  end
  describe "GET games" do
    it "gets the page without error" do
      visit games_path
      page.should have_content('Games')
    end
    it "gets the page without error when there is one simulator with games" do
      @game = Game.make
      @simulator.games << @game
      visit games_path
      page.should have_content(@game.name)
    end
    it "gets the page without error when there are two simulators with games", :js => true do
      @game = Game.make
      @simulator.games << @game
      @game2 = Game.make
      @simulator2.games << @game2
      visit games_path
      page.should have_content(@game.name)
      select @simulator2.fullname, :from => "simulator_id"
      page.should have_content(@game2.name)
    end
  end
  describe "GET games/new" do
    it "gets the page without error" do
      visit new_game_path
      page.should have_content('New Game')
    end
    it "respects the simulator select", :js => true do
      visit new_game_path
      select @simulator.fullname
      find_field("Number of agents").value.should == "120"
      select @simulator2.fullname
      find_field("Number of agents").value.should == "101"
      fill_in "Name", :with => "test"
      click_button "Create Game"
      save_and_open_page
      page.should have_content("Game was successfully created.")
      page.should have_content("101")
    end
  end
  # describe "GET games/1/features/new" do
  #   it "should load without error" do
  #     visit new_game_feature_path(@game)
  #     page.should have_content('Create feature')
  #   end
  #   it "should allow me to create without error" do
  #     visit new_game_feature_path(@game)
  #     fill_in "Name", :with => "Feature1"
  #     fill_in "Expected value", :with => "1.0"
  #     click_button "Create"
  #     page.should have_content('Feature was successfully created.')
  #     page.should have_content('Feature1')
  #     page.should have_content('1.0')
  #   end
  # end
  # describe "GET games/1/features/1" do
  #   it "should allow me to visit a feature" do
  #     @game.features.create!(:name => "Feature0001", :expected_value => 1.0)
  #     visit game_features_path(@game)
  #     click_on "Feature0001"
  #     page.should have_content('Feature Information')
  #   end
  #   it "should allow me to edit a feature" do
  #     @game.features.create!(:name => "Feature0001", :expected_value => 1.0)
  #     visit game_features_path(@game)
  #     click_on "Feature0001"
  #     click_on "Edit feature"
  #     page.should have_content('Edit feature')
  #     fill_in "Expected value", :with => "0.5"
  #     click_button "Update"
  #     page.should have_content('Feature was successfully updated.')
  #     page.should have_content('Feature Information')
  #     page.should have_content('0.5')
  #   end
end
