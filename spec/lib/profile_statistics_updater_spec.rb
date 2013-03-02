require 'profile_statistics_updater'

describe ProfileStatisticsUpdater do
  describe 'update' do
    it 'updates the statistics on the profile and its symmetry groups' do
      profile, symmetry_group, payoffs = stub, stub, stub
      profile.should_receive(:update_sample_count)
      profile.should_receive(:symmetry_groups).and_return([symmetry_group])
      profile.should_receive(:payoffs_for).with(symmetry_group).and_return(payoffs)
      symmetry_group.should_receive(:update_statistics).with(payoffs)
      profile.should_receive(:save!)
      ProfileStatisticsUpdater.update(profile)
    end
  end
end