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
  
  # describe "#destroy" do
  #   let!(:strategy){Fabricate(:strategy, :name => "A")}
  #   let!(:profile){Fabricate(:profile)}
  #   let!(:game_scheduler){Fabricate(:game_scheduler, :simulator => profile.simulator)}
  #   it "should preserve profiles" do
  #     game_scheduler.profile_ids << profile.id
  #     game_scheduler.save!
  #     GameScheduler.first.destroy
  #     Profile.count.should == 1
  #   end
  # end
  # 
  describe "adding a strategy" do
    let!(:game_scheduler){Fabricate(:game_scheduler)}
    
    it "should create profiles" do
      s = Fabricate(:strategy)
      simulator = game_scheduler.simulator
      simulator.roles.create(:name => "All")
      simulator.roles.first.strategies << s
      simulator.save
      game_scheduler.add_role("All", 2)
      visit game_scheduler_path(game_scheduler.id)
      click_on "Add Strategy"
      GameScheduler.first.roles.first.strategies.count.should == 1
      ResqueSpec.perform_all(:profile_actions)
      GameScheduler.first.profile_ids.size.should == 1
    end
  end
  # 
  # describe "#remove_strategy" do
  #   let!(:game_scheduler){Fabricate(:game_scheduler)}
  #   it "should preserve profiles" do
  #     game_scheduler.add_role("All", 2)
  #     game_scheduler.add_strategy("All", "A")
  #     ResqueSpec.perform_all(:profile_actions)
  #     game_scheduler = GameScheduler.first
  #     game_scheduler.remove_strategy("All", "A")
  #     GameScheduler.first.profile_ids.size.should == 0
  #     Profile.count.should == 1
  #   end
  # end
end