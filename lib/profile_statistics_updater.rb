class ProfileStatisticsUpdater
  def self.update(profile)
    profile.update_sample_count
    profile.symmetry_groups.each do |symmetry_group|
      payoffs = profile.payoffs_for(symmetry_group)
      symmetry_group.update_statistics(payoffs)
    end
    profile.save!
  end
end