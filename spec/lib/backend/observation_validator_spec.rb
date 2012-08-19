require 'spec_helper'

describe ObservationValidator do
  describe 'validate' do
    let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    context 'valid file' do
      let(:hash){ {
                    features: { 
                      "featureA" => 34.0, 
                      "featureB" => [37, 38], 
                      "featureC" => { 
                        "subfeature1" => 40.0, "subfeature2" => 42.0 
                      }
                    },
                    symmetry_groups: [
                      { 
                        role: 'Buyer', 
                        strategy: 'BidValue',
                        count: 2,
                        players: [
                          { 
                            payoff: 2992.73,
                  			    features: {
                  				    "featureA" => 0.001,
                  				    "featureB" => [2.0, 2.1]
                  			    }
                  			  },
                  			  {
                  			    payoff: 2990.53,
                    			  features: {
                    				  "featureA" => 0.002,
                    				  "featureB" => [2.0, 2.1]
                    			  }
                  			  }
                        ], 
                        payoff: (2992.73+2990.53)/2, 
                        payoff_sd: Math.sqrt((2992.73**2.0+2990.53**2.0)/2.0-((2992.73+2990.53)/2)**2.0) 
                      },
                      {
                        role: 'Seller',
                        strategy: 'Shade1', 
                        count: 1,
                        players: [
                          payoff: 2929.34,
                  			  features: {
                  				  "featureA" => 0.003,
                  				  "featureB" => [1.3, 1.7]
                  			  }
                        ], 
                        payoff: 2929.34,
                        payoff_sd: 0.0
                      },
                      {
                        role: 'Seller', 
                        strategy: 'Shade2',
                        count: 1,
                        players: [
                  			  payoff: 2924.44,
                  			  features: {
                  				  "featureA" => 0.003,
                  				  "featureB" => [1.4, 1.7]
                  			  }
                        ], 
                        payoff: 2924.44, 
                        payoff_sd: 0.0
                      }
                    ]
                  }
                }
      
      it { ObservationValidator.validate(profile, "#{Rails.root}/db/3/observation1.json").should eql(hash) }
    end
    
    context 'mismatched profiles do not get processed' do
      let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade0, 1 Shade1') }
      let(:json){ Oj.load_file("#{Rails.root}/db/3/observation1.json") }
      
      it { ObservationValidator.validate(profile, "#{Rails.root}/db/3/observation1.json").should eql(nil) }
    end
   
    context 'non-numeric payoffs cause processing to stop' do
      it { ObservationValidator.validate(profile, "#{Rails.root}/db/4/broken_payoff_observation1.json").should eql(nil) }
    end
      
    context 'NaN payoffs cause processing to stop' do
      it { ObservationValidator.validate(profile, "#{Rails.root}/db/4/nan_observation.json").should eql(nil) }
    end
      
    context 'String numeric payoffs get converted to floats' do
      let(:json){ Oj.load_file("#{Rails.root}/db/4/string_observation.json") }
      
      it { ObservationValidator.validate(profile, "#{Rails.root}/db/4/string_observation.json")[:symmetry_groups][0][:players][0][:payoff].should eql(2923.43) }
    end
  end
end