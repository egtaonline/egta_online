require 'spec_helper'

describe "Features" do
  
  describe "POST /games/:game_id/features" do
    it "creates a feature on the game" do
      game = Fabricate(:game)
      visit game_path(game.id)
      fill_in "name", :with => "feature1"
      fill_in "expected_value", :with => "0.5"
      click_button "Add Feature"
      page.should have_content("feature1")
      page.should have_content("0.5")
    end
  end
  
  describe "DELETE /games/:game_id/features/:id" do
    it "destroys the relevant feature, leaving the others" do
      game = Fabricate(:game)
      feature1 = Fabricate(:feature, :cv_manager => game.cv_manager)
      feature2 = Fabricate(:feature, :cv_manager => game.cv_manager)
      visit game_path(game.id)
      click_on "Remove Feature"
      Game.last.cv_manager.features.count.should eql(1)
      page.should have_content("Inspect Game")
    end
  end
end