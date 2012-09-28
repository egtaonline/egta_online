class HierarchicalDeviationScheduler < AbstractionDeviationScheduler
  def profile_space
    return [] if invalid_role_partition?
    prof_hashes = []
    reduced_game_with_devs.each do |reduced_profile|
      full_profile = {}
      roles.each do |role|
        full_profile[role.name] = AbstractionScheduler.fill_role(reduced_profile[role.name], role.count)
      end
      prof_hashes << full_profile
    end
    prof_hashes.uniq.collect{ |profile| dehasherize(profile) }
  end

  protected

  def add_strategies_to_game(game)
    super
    deviating_roles.each{ |r| r.strategies.each{ |s| game.add_strategy(r.name, s) } }
  end
end