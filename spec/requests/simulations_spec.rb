require 'spec_helper'

describe "Simulations" do

  let!(:simulation){Fabricate(:simulation)}
  
  context "GET /simulations" do
    it "displays simulations" do
      visit simulations_path
      page.should have_content("Simulations")
      page.should have_content(simulation.profile.name)
      page.should have_content(simulation.number)
      page.should have_content(simulation.state)
    end
  end
  
  context "GET /simulations/:id" do
    it "displays the relevant simulator" do
      visit simulation_path(simulation.id)
      page.should have_content("Inspect Simulation")
      page.should have_content(simulation.profile.name)
      page.should have_content(simulation.number)
      page.should have_content(simulation.state)
      page.should have_content(simulation.scheduler.simulator.fullname)
      page.should have_content(simulation.account_username)
    end
  end
end