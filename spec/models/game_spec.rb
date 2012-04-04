require 'spec_helper'

describe Game do
  describe "after_create" do
    before(:each) do
      ResqueSpec.reset!
    end
    
    let!(:game){Fabricate(:game)}
    it "should look for profiles after being created" do
      ProfileGatherer.should have_queued(game.id)
    end
  end
  
  describe "#display_profiles" do
    context "symmetric game" do
      let!(:game){Fabricate(:game)}
      let!(:profile){Fabricate(:profile, :simulator => game.simulator)}
      let!(:sample_record){Fabricate(:sample_record, :profile => profile)}
      let!(:profile2){Fabricate(:profile, :simulator => game.simulator, :name => "All: 1 A, 1 B")}
      let!(:sample_record2){Fabricate(:sample_record, :profile => profile2)}
      
      before(:each) do
        game.roles.create(:name => "All", :count => 2)
        game.profile_ids << profile.id
        game.profile_ids << profile2.id
        game.save
      end
      
      it "should match against profiles that are made of the constituent strategies" do
        game.add_strategy("All", "A")
        game.display_profiles.count.should_not eql(0)
      end
      
      it "should match only profiles that have strategies within the strategy set" do
        game.add_strategy("All", "A")
        game.display_profiles.count.should eql(1)
        game.display_profiles.first.should eql(profile)
      end
    end
    
    context "role-symmetric game" do
      let!(:game){Fabricate(:game)}
      let!(:profile){Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 A; Seller: 1 B")}
      let!(:sample_record){Fabricate(:sample_record, :profile => profile)}
      let!(:profile2){Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 A; Seller: 1 A")}
      let!(:sample_record2){Fabricate(:sample_record, :profile => profile2)}
      
      before(:each) do
        game.profile_ids << profile.id
        game.profile_ids << profile2.id
        game.save
      end
      
      it "should match against profiles that are made of the constituent strategies" do
        game.roles.create(:name => "Bidder", :count => 1)
        game.roles.create(:name => "Seller", :count => 1)
        game.add_strategy("Bidder", "A")
        game.add_strategy("Seller", "A")
        game.display_profiles.count.should_not eql(0)
      end
      
      it "should match only profiles that have strategies within the strategy set" do
        game.roles.create(:name => "Bidder", :count => 1)
        game.roles.create(:name => "Seller", :count => 1)
        game.add_strategy("Bidder", "A")
        game.add_strategy("Bidder", "B")
        game.add_strategy("Seller", "A")
        game.display_profiles.count.should eql(1)
        game.display_profiles.first.should eql(profile2)
      end
      
      it "should match only profiles that have the right role counts" do
        game.update_attribute(:size, 3)
        game.roles.create(:name => "Seller", :count => 2)
        game.roles.create(:name => "Bidder", :count => 1)
        game.add_strategy("Bidder", "B")
        game.add_strategy("Seller", "B")
        profile3 = Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 2 B; Seller: 1 B")
        Fabricate(:sample_record, :profile => profile3)
        game.profile_ids << profile3.id
        game.save
        game.display_profiles.count.should eql(0)
        profile4 = Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 B; Seller: 2 B")
        Fabricate(:sample_record, :profile => profile4)
        game.profile_ids << profile4.id
        game.save
        game.display_profiles.count.should eql(1)
        game.display_profiles.first.should eql(profile4)
      end
    end
  end
  
  describe "new_game_from_scheduler" do
    context "game schedulers" do
      let!(:game_scheduler){Fabricate(:game_scheduler)}
      it "should create a game that matches the scheduler" do
        g = Game.new_game_from_scheduler(game_scheduler)
        g.size.should eql(game_scheduler.size)
        g.simulator.should eql(game_scheduler.simulator)
        g.parameter_hash.should eql(game_scheduler.parameter_hash)
      end
    end
  end
  
  describe "#add_roles_from_scheduler" do
    context 'hierarchical schedulers' do
      let!(:scheduler){Fabricate(:hierarchical_scheduler)}
      it "should create a game that matches the scheduler" do
        scheduler.add_role("All", 2)
        scheduler.reload
        g = Game.new_game_from_scheduler(scheduler)
        g.add_roles_from_scheduler(scheduler)
        g.size.should eql(scheduler.size)
        g.simulator.should eql(scheduler.simulator)
        g.parameter_hash.should eql(scheduler.parameter_hash)
        g.roles.count.should eql(1)
        g.roles.first.name.should eql(scheduler.roles.first.name)
        g.roles.first.count.should eql(scheduler.roles.first.count*scheduler.agents_per_player)
      end
    end
    
    context 'game schedulers' do
      let!(:scheduler){Fabricate(:game_scheduler)}
      it "should create a game that matches the scheduler" do
        scheduler.add_role("All", 2)
        scheduler.reload
        g = Game.new_game_from_scheduler(scheduler)
        g.add_roles_from_scheduler(scheduler)
        g.size.should eql(scheduler.size)
        g.simulator.should eql(scheduler.simulator)
        g.parameter_hash.should eql(scheduler.parameter_hash)
        g.roles.count.should eql(1)
        g.roles.first.name.should eql(scheduler.roles.first.name)
        g.roles.first.count.should eql(scheduler.roles.first.count)
      end
    end
  end
  
  describe "destroy" do
    let!(:game){Fabricate(:game)}
    let!(:profile){Fabricate(:profile, :simulator => game.simulator)}
    it "should preserve profiles" do
      game.profile_ids << profile.id
      game.save!
      Game.first.destroy
      Profile.count.should == 1
    end
  end
end