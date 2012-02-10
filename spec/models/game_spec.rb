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
      let!(:strategy){Fabricate(:strategy, :name => "A", :number => 2)}
      let!(:strategy2){Fabricate(:strategy, :name => "B", :number => 1)}
      let!(:profile){Fabricate(:profile, :simulator => game.simulator, :sampled => true)}
      let!(:profile2){Fabricate(:profile, :simulator => game.simulator, :proto_string => "All: 2, 1", :sampled => true)}
      
      before(:each) do
        game.roles.create(:name => "All", :count => 2)
        game.profile_ids << profile.id
        game.profile_ids << profile2.id
        game.save
      end
      
      it "should match against profiles that are made of the constituent strategies" do
        game.add_strategy("All", "B")
        game.display_profiles.count.should_not eql(0)
      end
      
      it "should match only profiles that have strategies within the strategy set" do
        game.add_strategy("All", "B")
        game.display_profiles.count.should eql(1)
        game.display_profiles.first.should eql(profile)
      end
    end
    
    context "role-symmetric game" do
      let!(:game){Fabricate(:game)}
      let!(:strategy){Fabricate(:strategy, :name => "A", :number => 2)}
      let!(:strategy2){Fabricate(:strategy, :name => "B", :number => 1)}
      let!(:profile){Fabricate(:profile, :simulator => game.simulator, :proto_string => "Bidder: 2; Seller: 1", :sampled => true)}
      let!(:profile2){Fabricate(:profile, :simulator => game.simulator, :proto_string => "Bidder: 2; Seller: 2", :sampled => true)}
      
      before(:each) do
        game.profile_ids << profile.id
        game.profile_ids << profile2.id
        game.save
      end
      
      it "should match against profiles that are made of the constituent strategies" do
        puts Profile.all.to_a.inspect
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
        profile3 = Fabricate(:profile, :simulator => game.simulator, :proto_string => "Bidder: 1, 1; Seller: 1", :sampled => true)
        game.profile_ids << profile3.id
        game.save
        game.display_profiles.count.should eql(0)
        profile4 = Fabricate(:profile, :simulator => game.simulator, :proto_string => "Bidder: 1; Seller: 1, 1", :sampled => true)
        game.profile_ids << profile4.id
        game.save
        game.display_profiles.count.should eql(1)
        game.display_profiles.first.should eql(profile4)
      end
    end
  end
  
  describe "new_game_from_scheduler" do
    let!(:game_scheduler){Fabricate(:game_scheduler)}
    it "should create a game that matches the scheduler" do
      g = Game.new_game_from_scheduler(game_scheduler)
      g.size.should eql(game_scheduler.size)
      g.simulator.should eql(game_scheduler.simulator)
      g.parameter_hash.should eql(game_scheduler.parameter_hash)
    end
  end
  
  describe "destroy" do
    let!(:game){Fabricate(:game)}
    let!(:strategy){Fabricate(:strategy, :name => "A")}
    let!(:profile){Fabricate(:profile, :simulator => game.simulator)}
    it "should preserve profiles" do
      game.profile_ids << profile.id
      game.save!
      Game.first.destroy
      Profile.count.should == 1
    end
  end
end