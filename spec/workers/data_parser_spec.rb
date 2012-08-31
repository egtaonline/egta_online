require 'spec_helper'

describe DataParser do
  ### Integration test, consider pulling to cucumber and writing unit tests
  describe 'perform' do
    let(:profile){ double(assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let(:simulation){ double(profile: profile) }

    context 'multiple valid observations' do
      before do
        ObservationValidator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/3", ['observation1.json', 'observation2.json']).and_return([double('fake_json'), double('more fake_json')])
        Simulation.stub(:find).with(3).and_return(simulation)
        profile.stub_chain(:observations, :create!)
        profile.should_receive(:update_symmetry_group_payoffs)
      end

      it 'completes successfully' do
        simulation.should_receive(:finish!)
        DataParser.perform(3, "#{Rails.root}/db/3")
      end
    end

    context 'some failures' do
      before do
        ObservationValidator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/4", ['broken_payoff_observation1.json', 'nan_observation.json', 'string_observation.json']).and_return([double('fake_json')])
        Simulation.stub(:find).with(4).and_return(simulation)
        profile.stub_chain(:observations, :create!)
        profile.should_receive(:update_symmetry_group_payoffs)
      end

      it 'does a reasonable job with partial completeness' do
        simulation.should_receive(:finish!)
        DataParser.perform(4, "#{Rails.root}/db/4")
      end
    end

    context 'all failures' do
      before do
        ObservationValidator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/5", ['broken_payoff_observation1.json', 'nan_observation.json']).and_return([])
        Simulation.stub(:find).with(5).and_return(simulation)
      end

      it 'fails the simulation if there are no valid files' do
        simulation.should_receive(:fail).with("No valid payoff files were found.")
        DataParser.perform(5, "#{Rails.root}/db/5")
      end
    end
  end
end