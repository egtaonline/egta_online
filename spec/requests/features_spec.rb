require 'spec_helper'

describe "Features" do
  before(:each) do
    @user = User.make!
    @game = Game.make!
    visit "/"
    fill_in "Email", :with => "test@test.com"
    fill_in "Password", :with => "stuff1"
    check "Remember me"
    click_button "Sign in"
  end
  describe "GET games/1/features" do
    it "gets the page without error" do
      visit game_features_path(@game)
      page.should have_content('Features')
    end
    it "gets the page without error when the game has features" do
      @game.features.create!(:name => "Feature0001", :expected_value => 1.0)
      visit game_features_path(@game)
      page.should have_content('Feature0001')
      page.should have_content('1.0')
    end
  end
  describe "GET games/1/features/new" do
    it "should load without error" do
      visit new_game_feature_path(@game)
      page.should have_content('Create feature')
    end
    it "should allow me to create without error" do
      visit new_game_feature_path(@game)
      fill_in "Name", :with => "Feature1"
      fill_in "Expected value", :with => "1.0"
      click_button "Create"
      page.should have_content('Feature was successfully created.')
      page.should have_content('Feature1')
      page.should have_content('1.0')
    end
  end
  describe "GET games/1/features/1" do
    it "should allow me to visit a feature" do
      @game.features.create!(:name => "Feature0001", :expected_value => 1.0)
      visit game_features_path(@game)
      click_on "Feature0001"
      page.should have_content('Feature Information')
    end
    it "should allow me to edit a feature" do
      @game.features.create!(:name => "Feature0001", :expected_value => 1.0)
      visit game_features_path(@game)
      click_on "Feature0001"
      click_on "Edit feature"
      page.should have_content('Edit feature')
      fill_in "Expected value", :with => "0.5"
      click_button "Update"
      page.should have_content('Feature was successfully updated.')
      page.should have_content('Feature Information')
      page.should have_content('0.5')
    end
  end
end
