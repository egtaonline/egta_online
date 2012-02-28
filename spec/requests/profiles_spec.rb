require 'spec_helper'

describe "Profiles" do
  before(:each) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end
  
  describe "GET /profiles/:id" do
    it "should show that profile" do
      Fabricate(:strategy)
      profile = Fabricate(:profile)
      visit profile_path(profile.id)
      page.should have_content(profile.name)
    end
  end
end