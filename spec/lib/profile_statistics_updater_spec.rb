require 'profile_statistics_updater'
require 'spec_helper'

describe ProfileStatisticsUpdater do
  describe 'update' do
    let(:profile){ Fabricate(:profile_with_observation) }

    it 'updates the statistics on the profile and its symmetry groups' do
      payoffs = profile.observations.first.observation_symmetry_groups.first.players.collect{ |p| p["p"] }
      ProfileStatisticsUpdater.update(profile)
      Profile.find(profile.id).symmetry_groups.first.payoff.should == ArrayMath.average(payoffs)
      symmetry_group = profile.symmetry_groups.first
      profile.observations.create(observation_symmetry_groups: [{players: [{"p" => 300}, {"p" => 400}], payoff: 350.0, payoff_sd: Math.sqrt(7000)}])
      ProfileStatisticsUpdater.update(profile)
      Profile.find(profile.id).symmetry_groups.first.payoff.should == ArrayMath.average(payoffs+[300, 400])
    end
  end
end