require 'spec_helper'

describe "Simulators" do
  describe "GET /simulators" do
    it "displays simulators" do
      simulator = Fabricate(:simulator)
      visit simulators_path
      page.should have_content(simulator.name)
      page.should have_content(simulator.version)
    end
  end
  
  describe "GET /simulators/:id" do
    it "displays the relevant simulator" do
      simulator = Fabricate(:simulator)
      visit simulator_path(simulator.id)
      page.should have_content(simulator.name)
      page.should have_content(simulator.version)
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
  
  describe "POST /simulators/:id/remove_role" do
    it "removes the relevant role" do
      simulator = Fabricate(:simulator)
      simulator.add_strategy("Bidder", "A")
      visit simulator_path(simulator.id)
      click_on "Remove Role"
      page.should have_content("Inspect Simulator")
      page.should have_content(simulator.name)
      page.should_not have_content("Bidder")
      page.should_not have_content("Some errors were found")
      Simulator.last.roles.count.should eql(0)
    end
  end
  
  context "GET /simulators/:id/edit" do
    it "should show the edit page for the simulator" do
      simulator = Fabricate(:simulator)
      visit edit_simulator_path(simulator.id)
      page.should have_content("Edit Simulator")
      page.should have_content("Email")
      page.should have_content("Description")
      page.should have_content("Simulator source")
    end
  end

  context "PUT /simulators/:id" do
    it "should update the relevant simulator" do
      simulator = Fabricate(:simulator)
      visit edit_simulator_path(simulator.id)
      attach_file "Simulator source", "#{Rails.root}/spec/support/epp_sim.zip"
      click_button "Update Simulator"
      page.should have_content("Inspect Simulator")
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
  
  describe "POST /simulators/:id/add_role" do
    it "should add the required role" do
      simulator = Fabricate(:simulator)
      visit simulator_path(simulator.id)
      fill_in "role", :with => "All"
      click_button "Add Role"
      page.should have_content("Inspect Simulator")
      page.should have_content("All")
      page.should_not have_content("Some errors were found")
      Simulator.last.roles.count.should eql(1)
    end
  end
  
  describe "POST /simulators/:id/add_strategy" do
    it "should add the required strategy" do
      simulator = Fabricate(:simulator)
      simulator.add_role("All")
      visit simulator_path(simulator.id)
      fill_in "All_strategy", :with => "StratA"
      click_button "Add Strategy"
      page.should have_content("Inspect Simulator")
      page.should have_content("StratA")
      page.should_not have_content("Some errors were found")
      Simulator.last.roles.count.should eql(1)
      Simulator.last.roles.last.strategies.count.should eql(1)
    end
  end
  
  describe "POST /simulators/:id/remove_strategy" do
    it "should remove the required strategy" do
      simulator = Fabricate(:simulator)
      simulator.add_strategy("All", "StratA")
      visit simulator_path(simulator.id)
      click_on "Remove Strategy"
      page.should have_content("Inspect Simulator")
      page.should have_content("All")
      page.should_not have_content("StratA")
      page.should_not have_content("Some errors were found")
      Simulator.last.roles.count.should eql(1)
      Simulator.last.roles.last.strategies.count.should eql(0)
    end
  end
  
  describe "GET /simulators/new" do
    it "should render the new simulator form" do
      visit new_simulator_path
      page.should have_content("New Simulator")
      page.should have_content("Name")
      page.should have_content("Version")
      page.should have_content("Simulator source")
    end
  end
end