require 'spec_helper'

describe Game do
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :configuration }
  it { should validate_presence_of :size }
  it { should validate_presence_of :simulator_fullname }
  it { should validate_numericality_of(:size).to_allow(only_integer: true, greater_than: 1) }
  it { should embed_one(:cv_manager) }
  
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
      let(:profile){ Fabricate(:sampled_profile) }
      let(:profile2){ Fabricate(:sampled_profile, simulator: profile.simulator, assignment: "All: 1 A, 1 B") }
      let(:game){ with_resque{ Fabricate(:game, simulator: profile.simulator, configuration: profile.configuration, size: 2) } }
      
      before(:each) do
        game.reload.add_role("All", 2)
        game.add_strategy("All", "A")
      end
      
      it { game.display_profiles.count.should eql(1) }
      it { game.display_profiles.first.should eql(profile) }
    end
  #   
  #   context "role-symmetric game" do
  #     let!(:game){Fabricate(:game)}
  #     let!(:profile){Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 A; Seller: 1 B")}
  #     let!(:sample_record){Fabricate(:sample_record, :profile => profile)}
  #     let!(:profile2){Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 A; Seller: 1 A")}
  #     let!(:sample_record2){Fabricate(:sample_record, :profile => profile2)}
  #     
  #     before(:each) do
  #       game.profile_ids << profile.id
  #       game.profile_ids << profile2.id
  #       game.save
  #     end
  #     
  #     it "should match against profiles that are made of the constituent strategies" do
  #       game.roles.create(:name => "Bidder", :count => 1)
  #       game.roles.create(:name => "Seller", :count => 1)
  #       game.add_strategy("Bidder", "A")
  #       game.add_strategy("Seller", "A")
  #       game.display_profiles.count.should_not eql(0)
  #     end
  #     
  #     it "should match only profiles that have strategies within the strategy set" do
  #       game.roles.create(:name => "Bidder", :count => 1)
  #       game.roles.create(:name => "Seller", :count => 1)
  #       game.add_strategy("Bidder", "A")
  #       game.add_strategy("Bidder", "B")
  #       game.add_strategy("Seller", "A")
  #       game.display_profiles.count.should eql(1)
  #       game.display_profiles.first.should eql(profile2)
  #     end
  #     
  #     it "should match only profiles that have the right role counts" do
  #       game.update_attribute(:size, 3)
  #       game.roles.create(:name => "Seller", :count => 2)
  #       game.roles.create(:name => "Bidder", :count => 1)
  #       game.add_strategy("Bidder", "B")
  #       game.add_strategy("Seller", "B")
  #       profile3 = Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 2 B; Seller: 1 B")
  #       Fabricate(:sample_record, :profile => profile3)
  #       game.profile_ids << profile3.id
  #       game.save
  #       game.display_profiles.count.should eql(0)
  #       profile4 = Fabricate(:profile, :simulator => game.simulator, :name => "Bidder: 1 B; Seller: 2 B")
  #       Fabricate(:sample_record, :profile => profile4)
  #       game.profile_ids << profile4.id
  #       game.save
  #       game.display_profiles.count.should eql(1)
  #       game.display_profiles.first.should eql(profile4)
  #     end
  #   end
  end

  # 
  # describe "#add_roles_from_scheduler" do
  #   context 'hierarchical schedulers' do
  #     let!(:scheduler){Fabricate(:hierarchical_scheduler)}
  #     it "should create a game that matches the scheduler" do
  #       scheduler.add_role("All", 2)
  #       scheduler.reload
  #       g = Game.new_game_from_scheduler(scheduler)
  #       g.add_roles_from_scheduler(scheduler)
  #       g.size.should eql(scheduler.size)
  #       g.simulator.should eql(scheduler.simulator)
  #       g.configuration.should eql(scheduler.configuration)
  #       g.roles.count.should eql(1)
  #       g.roles.first.name.should eql(scheduler.roles.first.name)
  #       g.roles.first.count.should eql(scheduler.roles.first.count*scheduler.agents_per_player)
  #     end
  #   end
  #   
  #   context 'game schedulers' do
  #     let!(:scheduler){Fabricate(:game_scheduler)}
  #     it "should create a game that matches the scheduler" do
  #       scheduler.add_role("All", 2)
  #       scheduler.reload
  #       g = Game.new_game_from_scheduler(scheduler)
  #       g.add_roles_from_scheduler(scheduler)
  #       g.size.should eql(scheduler.size)
  #       g.simulator.should eql(scheduler.simulator)
  #       g.configuration.should eql(scheduler.configuration)
  #       g.roles.count.should eql(1)
  #       g.roles.first.name.should eql(scheduler.roles.first.name)
  #       g.roles.first.count.should eql(scheduler.roles.first.count)
  #     end
  #   end
  # end
  # 
  # describe "destroy" do
  #   let!(:game){Fabricate(:game)}
  #   let!(:profile){Fabricate(:profile, :simulator => game.simulator)}
  #   it "should preserve profiles" do
  #     game.profile_ids << profile.id
  #     game.save!
  #     Game.first.destroy
  #     Profile.count.should == 1
  #   end
  # end
end