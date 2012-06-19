require 'spec_helper'

describe DataParser do
  describe 'parse_file' do
    context 'valid file' do
      context 'single role' do
        let(:profile){ Fabricate(:profile, assignment: 'All: 2 BayesianPricing_noRA_0') }
        let(:simulation){ Fabricate(:simulation, profile: profile, number: 3) }
        
        before(:each) do
          @json = Oj.load_file("#{Rails.root}/db/3/observation1.json")
          DataParser.parse_file("#{Rails.root}/db/3/observation1.json", simulation)
          profile.reload
          simulation.reload
          @symmetry_group = profile.symmetry_groups.where(role: 'All', strategy: 'BayesianPricing_noRA_0').first
        end
        
        it{ @symmetry_group.players.count.should eql(2) }
        it{ @symmetry_group.players.first.payoff.should eql(@json['players'][0]['payoff']) }
        it{ @symmetry_group.players.first.features.should eql(@json['players'][0]['features']) }
        it{ @symmetry_group.players.last.payoff.should eql(@json['players'][1]['payoff']) }
        it{ @symmetry_group.players.first.features.should eql(@json['players'][0]['features']) }
        it{ profile.sample_count.should eql(1) }
        it{ simulation.files.should eql(['observation1.json']) }
        it{ profile.feature_observations.count.should eql(3) }
        it{ ['featureA', 'featureB', 'featureC'].each{ |feature| profile.feature_observations.where(observation_id: 1, name: feature).first.observation.should eql(@json['features'][feature]) } }
      end
    end
  end
end