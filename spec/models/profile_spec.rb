require 'spec_helper'

describe Profile do
  it { should embed_many :symmetry_groups }
  it { should embed_many :feature_observations }
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
  
  # 
  # describe "sample record observations work" do
  #   let!(:profile){Fabricate(:profile, :name => "All: 2 A")}
  #   let!(:sample_record){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>2}})}
  #   let!(:sample_record1){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>3}})}
  #   let!(:sample_record2){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>4}})}
  #   
  #   it "should dynamically update counts and payoffs" do
  #     profile.reload
  #     profile.sample_records.count.should eql(3)
  #     profile.sample_count.should eql(3)
  #     profile.role_instances.first.strategy_instances.first.payoff.should eql(3.0)
  #     profile.role_instances.first.strategy_instances.first.payoff_sd.should eql(1.0)
  #     profile.sample_records.last.destroy
  #     profile.reload
  #     profile.sample_count.should eql(2)
  #     profile.role_instances.first.strategy_instances.first.payoff.should eql(2.5)
  #     profile.role_instances.first.strategy_instances.first.payoff_sd.round(3).should eql(0.707)
  #   end
  # end
end