require 'spec_helper'

describe Profile do
  describe '#as_map' do
    let(:profile){Fabricate(:profile, :name => "Bidder: 1 Strat1, 1 Strat2; Seller: 2 Strat3")}
    it 'creates the map of roles and strategies' do
      profile.as_map.should eql({"Bidder" => ["Strat1", "Strat2"], "Seller" => ["Strat3", "Strat3"]})
    end
  end
  
  describe 'generate_roles' do
    let(:profile){Fabricate(:profile, :name => "Bidder: 1 Strat1, 1 Strat2; Seller: 2 Strat3")}
    it 'makes the role instances necessary for the profile before saving' do
      profile.role_instances.count.should eql(2)
      profile.role_instances.first.name.should eql("Bidder")
      profile.role_instances.first.strategy_instances.first.name.should eql("Strat1")
      profile.role_instances.first.strategy_instances.last.name.should eql("Strat2")
      profile.role_instances.last.name.should eql("Seller")
      profile.role_instances.last.strategy_instances.last.name.should eql("Strat3")
      profile["Role_Bidder_count"].should eql(2)
      profile["Role_Seller_count"].should eql(2)
      profile.size.should eql(4)
    end
  end
  
  describe '#strategy_count' do
    let(:profile){Fabricate(:profile, :name => "Bidder: 1 Strat1, 1 Strat2; Seller: 2 Strat3")}
    context 'when the role and strategy exists' do
      it { profile.strategy_count("Bidder", "Strat1").should eql(1) }
      it { profile.strategy_count("Bidder", "Strat2").should eql(1) }
      it { profile.strategy_count("Seller", "Strat3").should eql(2) }
    end
    
    context 'when the role or strategy does not exist' do
      it{ profile.strategy_count("Bidder", "Strat3").should eql(0) }
      it{ profile.strategy_count("Bidder", "Strat4").should eql(0) }
      it{ profile.strategy_count("All", "Strat1").should eql(0) }
    end
  end
  
  describe "sample record observations work" do
    let!(:profile){Fabricate(:profile, :name => "All: 2 A")}
    let!(:sample_record){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>2}})}
    let!(:sample_record1){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>3}})}
    let!(:sample_record2){Fabricate(:sample_record, :profile => profile, :payoffs => {"All"=>{"A"=>4}})}
    
    it "should dynamically update counts and payoffs" do
      profile.reload
      profile.sample_records.count.should eql(3)
      profile.sample_count.should eql(3)
      profile.role_instances.first.strategy_instances.first.payoff.should eql(3.0)
      profile.role_instances.first.strategy_instances.first.payoff_sd.should eql(1.0)
      profile.sample_records.last.destroy
      profile.reload
      profile.sample_count.should eql(2)
      profile.role_instances.first.strategy_instances.first.payoff.should eql(2.5)
      profile.role_instances.first.strategy_instances.first.payoff_sd.round(3).should eql(0.707)
    end
  end
end