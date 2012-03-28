require 'spec_helper'

describe "Profiles" do
  
  describe "GET /profiles/:id" do
    it "should show that profile" do
      profile = Fabricate(:profile)
      visit profile_path(profile.id)
      page.should have_content(profile.name)
    end
  end
end