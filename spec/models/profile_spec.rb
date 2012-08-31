require 'spec_helper'

describe Profile do
  it { should embed_many :symmetry_groups }
  it { should embed_many :observations }
  it { should have_field :configuration }
  
  describe "uniqueness validation" do
    let!(:existing_profile){ Fabricate(:profile, assignment: "A: 1 StratA, 1 StratB; B: 2 StratC") }
    let!(:new_profile){ Fabricate.build(:profile, simulator: existing_profile.simulator, configuration: existing_profile.configuration, 
                                                 assignment: "B: 2 StratC; A: 1 StratB, 1 StratA") }
    it "should identify violations of the uniqueness constraints" do
      new_profile.valid?.should eql(false)
      new_profile.errors[:assignment].should eql(["is already taken"])
    end
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