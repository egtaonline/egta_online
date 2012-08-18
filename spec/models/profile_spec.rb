require 'spec_helper'

describe Profile do
  it { should embed_many :symmetry_groups }
  it { should embed_many :observations }
  it { should have_field :configuration }
  
  describe 'scopes' do
    let(:matching_profile){ Fabricate(:profile) }
    let(:non_matching_profile){ Fabricate(:profile) }
    
    describe 'with_game' do
      let(:game_to_match){ Fabricate(:game) }
      let(:other_game){ Fabricate(:game) }
      
      before do
        matching_profile.games << game_to_match
        non_matching_profile.games << other_game
      end
      
      it { Profile.with_game(game_to_match).to_a.should eql([matching_profile]) }
    end
    
    describe 'with_scheduler' do
      let(:scheduler_to_match){ Fabricate(:hierarchical_deviation_scheduler) }
      let(:other_scheduler){ Fabricate(:game_scheduler) }
      
      before do
        matching_profile.schedulers << scheduler_to_match
        non_matching_profile.schedulers << other_scheduler
      end
      
      it { Profile.with_scheduler(scheduler_to_match).to_a.should eql([matching_profile]) }
    end
  end
  
  describe "uniqueness validation" do
    let!(:existing_profile){ Fabricate(:profile, assignment: "A: 1 StratA, 1 StratB; B: 2 StratC") }
    let!(:new_profile){ Fabricate.build(:profile, simulator: existing_profile.simulator, configuration: existing_profile.configuration, 
                                                 assignment: "B: 2 StratC; A: 1 StratB, 1 StratA") }
    it "should identify violations of the uniqueness constraints" do
      new_profile.valid?.should eql(false)
      new_profile.errors[:assignment].should eql(["is already taken"])
    end
  end
  
  describe "looks for games after creation" do
    before do
      ResqueSpec.reset!
    end
    
    let(:profile){ Fabricate(:profile) }
    it { GameAssociater.should have_queued(profile.id) }
  end
  
  describe "#try_scheduling" do
    before do
      ResqueSpec.reset!
    end
    
    let(:profile){ Fabricate(:profile) }
    
    before(:each) do
      profile.try_scheduling
    end
    it { ProfileScheduler.should have_scheduled(profile.id).in(5 * 60) }
  end
end