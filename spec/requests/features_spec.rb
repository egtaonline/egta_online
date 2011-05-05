require 'spec_helper'

describe "Features" do
  describe "GET games/1/features" do
    before(:each) do
      @user = User.make!
      @game = Game.make!
      visit "/"
      fill_in "Email", :with => "test@test.com"
      fill_in "Password", :with => "stuff1"
      check "Remember me"
      click_button "Sign in"
    end
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
end
