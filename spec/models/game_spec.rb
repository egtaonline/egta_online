require 'spec_helper'

describe Game do
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :configuration }
  it { should validate_presence_of :size }
  it { should validate_presence_of :simulator_fullname }
  it { should validate_numericality_of(:size).to_allow(only_integer: true, greater_than: 0) }
  
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
      let(:profile){ Fabricate(:sampled_profile, assignment: 'All: 2 A') }
      let(:profile2){ Fabricate(:sampled_profile, simulator: profile.simulator, assignment: "All: 1 A, 1 B") }
      let(:game){ with_resque{ Fabricate(:game, simulator: profile.simulator, configuration: profile.configuration, size: 2) } }
      
      before(:each) do
        game.reload.add_role("All", 2)
        game.add_strategy("All", "A")
        game.reload
      end
      
      it { puts Profile.collection.find(:games_id=>game.id, :sample_count=>{"$gt"=>0}, :assignment=>/^All: \d+ (A(, \d+ )?)*$/, "role_All_count"=>2).count; Profile.collection.find(game.display_query).should eql(1) }
      it { Profile.collection.find(game.display_query).first.should eql(profile) }
    end
  end
end