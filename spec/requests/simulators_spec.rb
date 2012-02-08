require 'spec_helper'

describe "Simulators" do
  before(:each) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "GET /simulators" do
    it "displays simulators" do
      Fabricate(:simulator)
      visit simulators_path
      page.should have_content("epp_sim")
      page.should have_content("testing")
    end
  end
  
  describe "GET /simulators/:id" do
    it "displays the relevant simulator" do
      simulator = Fabricate(:simulator)
      visit simulator_path(simulator.id)
      page.should have_content("epp_sim")
      page.should have_content("testing")
    end
  end
  
  describe "POST /simulators" do
    before(:each) do
      ResqueSpec.reset!
    end
    
    it "creates a simulator" do
      visit new_simulator_path
      fill_in "Name", :with => "epp_sim"
      fill_in "Version", :with => "testing"
      attach_file "Simulator source", "#{Rails.root}/features/support/epp_sim.zip"
      click_button "Create Simulator"
      page.should have_content("epp_sim")
      page.should have_content("testing")
      SimulatorInitializer.should have_queue_size_of(1)
      page.should_not have_content("Some errors were found")
    end
  end
  
  describe "DELETE /simulators/:id/" do
    it "destroys the relevant simulator" do
      simulator = Fabricate(:simulator)
      visit simulators_path
      click_on "Destroy"
      Simulator.count.should eql(0)
    end
  end
end