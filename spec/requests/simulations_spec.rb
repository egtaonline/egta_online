require 'spec_helper'

describe "Simulations" do
  before(:each) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
    Fabricate(:strategy, :name => "A", :number => 1)
    @simulation = Fabricate(:simulation)
  end

  describe "GET /simulations" do
    it "displays simulations" do
      visit simulations_path
      page.should have_content("Simulations")
      page.should have_content(@simulation.profile.name)
      page.should have_content(@simulation.number)
      page.should have_content(@simulation.state)
    end
  end
  
  describe "GET /simulations/:id" do
    it "displays the relevant simulator" do
      visit simulation_path(@simulation.id)
      page.should have_content("Inspect Simulation")
      page.should have_content(@simulation.profile.name)
      page.should have_content(@simulation.number)
      page.should have_content(@simulation.state)
      page.should have_content(@simulation.scheduler.simulator.fullname)
      page.should have_content(@simulation.account_username)
    end
  end
end