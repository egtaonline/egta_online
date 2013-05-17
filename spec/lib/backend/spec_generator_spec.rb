require 'spec_helper'

describe SpecGenerator do
  describe 'generate' do
    let(:symmetry_group1){ double(role: 'Bidder', count: 2, strategy: 'Shade1') }
    let(:symmetry_group2){ double(role: 'Bidder', count: 1, strategy: 'Shade2') }
    let(:symmetry_group3){ double(role: 'Seller', count: 3, strategy: 'FirstPrice') }
    let(:symmetry_group4){ double(role: 'Seller', count: 1, strategy: 'SecondPrice') }
    let(:profile){ double(symmetry_groups: [symmetry_group1, symmetry_group2, symmetry_group3, symmetry_group4], configuration: { fake: 'value' }) }
    let(:simulation){ double(profile_id: 1, _id: 23, id: 23)}

    it 'creates a simulation_spec.json file' do
      criteria = double('Criteria')
      Profile.should_receive(:where).with(_id: 1).and_return(criteria)
      criteria.should_receive(:without).with(:observations).and_return([profile])
      Oj.should_receive(:to_file).with("#{Rails.root}/tmp/simulations/#{simulation.id}/simulation_spec.json",
                                       { "assignment" => { 'Bidder' => ['Shade1', 'Shade1', 'Shade2'], 'Seller' => ['FirstPrice', 'FirstPrice', 'FirstPrice', 'SecondPrice'] },
                                         "configuration" => profile.configuration },
                                       indent: 2)
      SpecGenerator.generate(simulation)
    end
  end
end