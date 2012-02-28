require 'spec_helper'

describe "GameSchedulers" do
  before(:each) do
    ResqueSpec.reset!
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "POST /schedulers/:id/add_strategy" do
    pending
  end
  
  describe "POST /game_schedulers/:id/remove_strategy" do
    pending
  end
end