require 'spec_helper'

describe DataParser do
  ### Integration test, consider pulling to cucumber and writing unit tests
  describe 'perform' do
    context 'multiple valid observations' do
      let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let!(:simulation){ Fabricate(:simulation, profile: profile, number: 3, size: 2) }
      
      before(:each) do
        DataParser.perform(3, "#{Rails.root}/db/3")
      end
      
      it{ simulation.reload.state.should eql('complete') }
      it{ simulation.reload.files.should eql(['observation1.json','observation2.json']) }
      it{ profile.reload.sample_count.should eql(2) }
    end
    
    context 'some failures' do
      let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let!(:simulation){ Fabricate(:simulation, profile: profile, number: 4, size: 3) }
      
      before(:each) do
        DataParser.perform(4, "#{Rails.root}/db/4")
      end
      it { simulation.reload.state.should eql('complete') }
      it { simulation.reload.files.should eql(['string_observation.json']) }
      it { profile.reload.sample_count.should eql(1) }
    end
    
    context 'all failures' do
      let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
      let!(:simulation){ Fabricate(:simulation, profile: profile, number: 5, size: 3) }
      
      before(:each) do
        DataParser.perform(5, "#{Rails.root}/db/5")
      end
      it { simulation.reload.state.should eql('failed') }
      it { simulation.reload.files.should eql([]) }
      it { profile.reload.sample_count.should eql(0) }
    end
  end
end