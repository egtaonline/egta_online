require 'spec_helper'

describe ObservationValidator do
  describe 'validate' do
    context 'valid file' do
      let(:json){ Oj.load_file("#{Rails.root}/db/3/observation1.json") }
      
      it { ObservationValidator.validate("#{Rails.root}/db/3/observation1.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2').should eql(json) }
    end
    
    context 'mismatched profiles do not get processed' do
      let(:json){ Oj.load_file("#{Rails.root}/db/3/observation1.json") }
      
      it { ObservationValidator.validate("#{Rails.root}/db/3/observation1.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade0').should eql(nil) }
    end
   
    context 'non-numeric payoffs cause processing to stop' do
      it { ObservationValidator.validate("#{Rails.root}/db/4/broken_payoff_observation1.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2').should eql(nil) }
    end
      
    context 'NaN payoffs cause processing to stop' do
      it { ObservationValidator.validate("#{Rails.root}/db/4/nan_observation.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2').should eql(nil) }
    end
      
    context 'String numeric payoffs get converted to floats' do
      let(:json){ Oj.load_file("#{Rails.root}/db/4/string_observation.json") }
      
      it { ObservationValidator.validate("#{Rails.root}/db/4/string_observation.json", 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2')['players'][0]['payoff'].should eql(json['players'][0]['payoff'].to_f) }
    end
  end
end