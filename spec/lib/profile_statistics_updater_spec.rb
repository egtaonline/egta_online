require 'profile_statistics_updater'
require 'spec_helper'

describe ProfileStatisticsUpdater do
  describe 'update' do
    let(:profile){ Fabricate(:profile_with_observation) }

    it 'updates the statistics on the profile and its symmetry groups' do
      ProfileStatisticsUpdater.update(profile)
      Profile.find(profile.id).symmetry_groups.first.payoff.should == 150
      symmetry_group = profile.symmetry_groups.first
      profile.observations.create(symmetry_groups: [{role: symmetry_group.role, strategy: symmetry_group.strategy, count: 2, players: [{payoff: 300}, {payoff: 400}]}])
      ProfileStatisticsUpdater.update(profile)
      Profile.find(profile.id).symmetry_groups.first.payoff.should == 250
    end
  end
end