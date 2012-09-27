class DprDeviationScheduler < AbstractionScheduler
  include Deviations

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

  private

  def reduced_game_with_devs
    profs = reduced_game
    reduced_game.each do |profile|
      profile.each do |role, strategy_hash|
        strategy_hash.each do |strategy, count|
          deviating_roles.where(name: role).first.strategies.each do |dev_strategy|
            dev_prof = profile.deep_copy
            if dev_prof[role][strategy] == 1
              dev_prof[role].delete(strategy)
            else
              dev_prof[role][strategy] -= 1
            end
            dev_prof[role][dev_strategy] ||= 0
            dev_prof[role][dev_strategy] += 1
            profs << dev_prof
          end
        end
      end
    end
    profs.uniq
  end
end