require 'spec_helper'

describe "Games" do
  describe "add strategy" do
    let!(:user) { Fabricate(:user) }
    let!(:game) { Fabricate(:symmetric_game) }
    before do
      visit "users/sign_in"
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      check "Remember me"
      click_button "Sign in"
      simulator = Simulator.new(:name => "A", :version => "B")
      simulator.stub(:setup_simulator).and_return(true)
      simulator.save!
      game.simulator = simulator
      game.save!
    end
    it "should allow me to add a strategy" do
      visit url_for(:controller => "documents", :class => "symmetric_game", :id => game.id)
    end
  end
end
