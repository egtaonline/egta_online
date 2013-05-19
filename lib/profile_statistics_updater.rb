class ProfileStatisticsUpdater
  def self.update(profile, jsons)
    tracker = {}
    addition = jsons.size
    jsons.each do |json|
      json[:symmetry_groups].each do |symmetry_group|
        tracker[symmetry_group[:role]] ||= {}
        tracker[symmetry_group[:role]][symmetry_group[:strategy]] ||= {}
        tracker[symmetry_group[:role]][symmetry_group[:strategy]]["count"] ||= 0
        tracker[symmetry_group[:role]][symmetry_group[:strategy]]["payoff"] ||= 0
        tracker[symmetry_group[:role]][symmetry_group[:strategy]]["payoff_square"] ||= 0
        symmetry_group[:players].each do |player|
          tracker[symmetry_group[:role]][symmetry_group[:strategy]]["count"] += 1
          tracker[symmetry_group[:role]][symmetry_group[:strategy]]["payoff"] += player[:payoff]
          tracker[symmetry_group[:role]][symmetry_group[:strategy]]["payoff_square"] += player[:payoff]**2.0
        end
      end
      begin
        profile.observations.create!(json)
      rescue
        addition -= 1
      end
    end
    profile.symmetry_groups.each do |symmetry_group|
      n = symmetry_group.count*profile.sample_count
      m = n + tracker[symmetry_group.role][symmetry_group.strategy]["count"]
      old_payoff = symmetry_group.payoff
      old_payoff ||= 0
      old_payoff_sum = old_payoff*n
      old_std = symmetry_group.payoff_sd
      old_std ||= 0
      new_payoff = (old_payoff_sum+tracker[symmetry_group.role][symmetry_group.strategy]["payoff"])/m
      payoff_square_sum = tracker[symmetry_group.role][symmetry_group.strategy]["payoff_square"]
      symmetry_group.set(:payoff, new_payoff)
      new_payoff_sd = Math.sqrt((n*(old_std**2.0+old_payoff**2.0)+payoff_square_sum)/m-new_payoff**2.0)
      symmetry_group.set(:payoff, new_payoff)
      symmetry_group.set(:payoff_sd, new_payoff_sd)
    end
    profile.set(:sample_count, profile.sample_count+addition)
  end
end