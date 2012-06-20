require 'spec_helper'

describe DataParser do
  describe 'parse_file' do
    context 'valid file' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 3) }
      
      before(:each) do
        @json = Oj.load_file("#{Rails.root}/db/3/observation1.json")
        DataParser.parse_file("#{Rails.root}/db/3/observation1.json", simulation)
        profile.reload
        simulation.reload
        @buyer_group = profile.symmetry_groups.where(role: 'Buyer').first
        @seller_group1 = profile.symmetry_groups.where(role: 'Seller', strategy: 'Shade1').first
        @seller_group2 = profile.symmetry_groups.where(role: 'Seller', strategy: 'Shade2').first
      end
      
      it{ @buyer_group.players.first.payoff.should eql(@json['players'][0]['payoff']) }
      it{ @buyer_group.players.last.payoff.should eql(@json['players'][2]['payoff']) }
      it{ @seller_group1.players.first.payoff.should eql(@json['players'][3]['payoff'])}
      it{ @seller_group2.players.first.payoff.should eql(@json['players'][1]['payoff'])}
      it{ @buyer_group.players.first.features.should eql(@json['players'][0]['features']) }
      it{ @buyer_group.players.last.features.should eql(@json['players'][2]['features']) }
      it{ @seller_group1.players.first.features.should eql(@json['players'][3]['features'])}
      it{ @seller_group2.players.first.features.should eql(@json['players'][1]['features'])}
      it{ profile.sample_count.should eql(1) }
      it{ simulation.files.should eql(['observation1.json']) }
      it{ profile.feature_observations.count.should eql(3) }
      it{ ['featureA', 'featureB', 'featureC'].each{ |feature| profile.feature_observations.where(observation_id: 1, name: feature).first.observation.should eql(@json['features'][feature]) } }
    end
    
    context 'previously seen file does not get processed' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 3) }
      
      before(:each) do
        profile.inc(:sample_count, 1)
        simulation.add_to_set(:files, 'observation1.json')
        DataParser.parse_file("#{Rails.root}/db/3/observation1.json", simulation)
      end
      
      it { profile.reload.sample_count.should eql(1) }
      it { simulation.reload.files.should eql(['observation1.json'])}
    end
    
    context 'mismatched profiles do not get processed' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 2 Shade1') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 3) }
      
      before(:each) do
        DataParser.parse_file("#{Rails.root}/db/3/observation1.json", simulation)
      end
      
      it { profile.reload.sample_count.should eql(0) }
      it { simulation.reload.files.should == [] }
    end
    
    context 'non-numeric payoffs cause processing to stop' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 4) }
      
      before(:each) do
        DataParser.parse_file("#{Rails.root}/db/4/broken_payoff_observation1.json", simulation)
      end
      
      it { profile.reload.sample_count.should eql(0) }
      it { simulation.reload.files.should == [] }
    end
    
    context 'NaN payoffs cause processing to stop' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 4) }
      
      before(:each) do
        DataParser.parse_file("#{Rails.root}/db/4/nan_observation.json", simulation)
      end
      
      it { profile.reload.sample_count.should eql(0) }
      it { simulation.reload.files.should == [] }
    end
    
    context 'String numeric payoffs get converted to floats' do
      let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let(:simulation){ Fabricate(:simulation, profile: profile, number: 4) }
      
      before(:each) do
        DataParser.parse_file("#{Rails.root}/db/4/string_observation.json", simulation)
      end
      
      before(:each) do
        @json = Oj.load_file("#{Rails.root}/db/4/string_observation.json")
        DataParser.parse_file("#{Rails.root}/db/4/string_observation.json", simulation)
        profile.reload
        simulation.reload
        @buyer_group = profile.symmetry_groups.where(role: 'Buyer').first
      end
      
      it{ @buyer_group.players.first.payoff.should eql(@json['players'][0]['payoff'].to_f) }
      it{ profile.sample_count.should eql(1) }
      it{ simulation.files.should eql(['string_observation.json']) }
    end
  end
end