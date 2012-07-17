require 'spec_helper'

describe SpecGenerator do
  describe 'generate' do
    let(:symmetry_group1){ double(role: 'Bidder', count: 2, strategy: 'Shade1') }
    let(:symmetry_group2){ double(role: 'Bidder', count: 1, strategy: 'Shade2') }
    let(:symmetry_group3){ double(role: 'Seller', count: 3, strategy: 'FirstPrice') }
    let(:symmetry_group4){ double(role: 'Seller', count: 1, strategy: 'SecondPrice') }
    let(:profile){ double(symmetry_groups: [symmetry_group1, symmetry_group2, symmetry_group3, symmetry_group4], configuration: { fake: 'value' }) }
    let(:simulation){ double(profile: profile, number: 23)}
    
    it 'creates a simulation_spec.json file' do
      Oj.should_receive(:to_file).with("#{Rails.root}/tmp/simulations/#{simulation.number}/simulation_spec.json",
                                       { assignment: { 'Bidder' => ['Shade1', 'Shade1', 'Shade2'], 'Seller' => ['FirstPrice', 'FirstPrice', 'FirstPrice', 'SecondPrice'] },
                                         configuration: profile.configuration },
                                       indent: 2)
      SpecGenerator.generate(simulation)
    end
  end
end