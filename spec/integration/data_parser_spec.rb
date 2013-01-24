require 'spec_helper'

describe DataParser do
  ### Integration test, consider pulling to cucumber and writing unit tests
  describe 'perform' do
    let(:profile){ Fabricate(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let(:simulation){ Fabricate(:simulation, profile: profile, state: 'running') }

    context 'multiple valid observations' do
      before do
        Simulation.stub(:find).with(3).and_return(simulation)
      end

      it 'completes successfully' do
        subject.perform(3, "#{Rails.root}/db/3")
        profile.reload
        profile.sample_count.should == 2
        profile.symmetry_groups.first.payoff.should == (2992.73+2990.53+2990.73+2690.53)/4.0
      end
    end
  end
end