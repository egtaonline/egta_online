require 'spec_helper'

describe DataParser do
  ### Integration test, consider pulling to cucumber and writing unit tests
  describe 'perform' do
    let(:profile){ double(assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let(:simulation){ double(profile_id: 1, state: 'running') }
    let(:validator){ double('validator') }
    let(:fake1){ double('fake_json') }
    let(:fake2){ double('more fake_json') }

    before do
      criteria = double("Criteria")
      Profile.should_receive(:where).with(_id: 1).and_return(criteria)
      criteria.should_receive(:without).with(:observations).and_return([profile])
      ObservationValidator.stub(:new).and_return(validator)
    end

    context 'multiple valid observations' do
      before do
        validator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/3", ['observation1.json', 'observation2.json']).and_return([fake1, fake2])
        Simulation.stub(:find).with(3).and_return(simulation)
        profile.stub_chain(:observations, :create!)
        ProfileStatisticsUpdater.should_receive(:update).with(profile, [fake1, fake2])
      end

      it 'completes successfully' do
        simulation.should_receive(:finish)
        subject.perform(3, "#{Rails.root}/db/3")
      end
    end

    context 'some failures' do
      before do
        validator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/4", ['broken_payoff_observation1.json', 'nan_observation.json', 'string_observation.json']).and_return([fake1])
        Simulation.stub(:find).with(4).and_return(simulation)
        profile.stub_chain(:observations, :create!)
        ProfileStatisticsUpdater.should_receive(:update).with(profile, [fake1])
      end

      it 'does a reasonable job with partial completeness' do
        simulation.should_receive(:finish)
        subject.perform(4, "#{Rails.root}/db/4")
      end
    end

    context 'all failures' do
      before do
        validator.should_receive(:validate_all).with(profile, "#{Rails.root}/db/5", ['broken_payoff_observation1.json', 'nan_observation.json']).and_return([])
        Simulation.stub(:find).with(5).and_return(simulation)
      end

      it 'fails the simulation if there are no valid files' do
        simulation.should_receive(:fail).with("No valid payoff files were found.")
        subject.perform(5, "#{Rails.root}/db/5")
      end
    end
  end
end