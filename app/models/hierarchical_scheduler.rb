class HierarchicalScheduler < AbstractionScheduler
  def profile_space
    return [] if invalid_role_partition?
    prof_hashes = []
    reduced_game.each do |reduced_profile|
      full_profile = {}
      roles.each do |role|
        full_profile[role.name] = AbstractionScheduler.fill_role(reduced_profile[role.name], role.count)
      end
      prof_hashes << full_profile
    end
    prof_hashes.collect{ |profile| dehasherize(profile) }
  end
end