class DprDeviationScheduler < AbstractionDeviationScheduler
  def add_role(name, count, reduced_count)
    super
    deviating_roles.find_or_create_by(name: name, count: count, reduced_count: reduced_count)
  end

  def profile_space
    return [] if invalid_role_partition?
    prof_hashes = []
    reduced_game_with_devs.each do |reduced_profile|
      roles.each do |role|
        reduced_profile[role.name].each do |strategy, count|
          full_profile = {}
          roles.each do |r|
            if role.name == r.name
              everyone_else = reduced_profile[r.name].dup
              everyone_else[strategy] -= 1
              full_profile[r.name] = AbstractionScheduler.fill_role(everyone_else, r.count-1)
              full_profile[r.name][strategy] += 1
            else
              full_profile[r.name] = AbstractionScheduler.fill_role(reduced_profile[r.name], r.count)
            end
          end
          prof_hashes << full_profile
        end
      end
    end
    prof_hashes.uniq.collect{ |profile| dehasherize(profile) }
  end
end