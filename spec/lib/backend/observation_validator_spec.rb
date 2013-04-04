require 'spec_helper'

describe ObservationValidator do
  describe 'validate' do
    let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 2 Shade1, 1 Shade2') }
    let(:simulator_instance){ double(:simulator_instance) }

    before do
      profile.stub(:simulator_instance).and_return(simulator_instance)
      simulator_instance.stub(:get_storage_key).with('featureA').and_return(1)
      simulator_instance.stub(:get_storage_key).with('featureB').and_return(2)
      simulator_instance.stub(:get_storage_key).with('featureC').and_return(3)
      simulator_instance.stub(:get_storage_key).with('subfeature1').and_return(4)
      simulator_instance.stub(:get_storage_key).with('subfeature2').and_return(5)
    end

    context 'valid file' do
      let(:hash){ {
                    features: {
                      1 => 34.0,
                      2 => [37, 38],
                      3 => {
                        4 => 40.0, 5 => 42.0
                      }
                    },
                    observation_symmetry_groups: [
                      {
                        players: [
                          {
                  				  1 => 0.001,
                  				  2 => [2.0, 2.1],
                  				  "p" => 2992.73
                  			  },
                  			  {
                    				1 => 0.002,
                    				2 => [2.0, 2.1],
                    			  "p" => 2990.53
                  			  }
                        ],
                        payoff: (2992.73+2990.53)/2,
                        payoff_sd: Math.sqrt((2992.73**2.0+2990.53**2.0)/2.0-((2992.73+2990.53)/2)**2.0)
                      },
                      {
                        players: [
                  				{
                  				  1 => 0.003,
                  				  2 => [1.3, 1.7],
                  				  "p" => nil
                  				},
                          {
                  				  1 => 0.003,
                  				  2 => [1.3, 1.7],
                            "p" => 2929.34
                  				}
                        ],
                        payoff: 2929.34,
                        payoff_sd: 0.0
                      },
                      {
                        players: [
                          {
                  				  1 => 0.003,
                  				  2 => [1.4, 1.7],
                  			    "p" => 2924.44
                  				}
                  			],
                        payoff: 2924.44,
                        payoff_sd: 0.0
                      }
                    ]
                  }
                }

      it { subject.validate(profile, "#{Rails.root}/db/3/observation1.json").should eql(hash) }
    end

    context 'mismatched profiles do not get processed' do
      let!(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade0, 1 Shade1') }
      let(:json){ Oj.load_file("#{Rails.root}/db/3/observation1.json") }

      it { subject.validate(profile, "#{Rails.root}/db/3/observation1.json").should eql(nil) }
    end

    context 'non-numeric payoffs cause processing to stop' do
      it { subject.validate(profile, "#{Rails.root}/db/4/broken_payoff_observation1.json").should eql(nil) }
    end

    context 'NaN payoffs cause processing to stop' do
      it { subject.validate(profile, "#{Rails.root}/db/4/nan_observation.json").should eql(nil) }
    end

    context 'String numeric payoffs get converted to floats' do
      let(:json){ Oj.load_file("#{Rails.root}/db/4/string_observation.json") }

      it { subject.validate(profile, "#{Rails.root}/db/4/string_observation.json")[:observation_symmetry_groups][0][:players][0]["p"].should eql(2923.43) }
    end
  end
end