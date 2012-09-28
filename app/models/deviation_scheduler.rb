class DeviationScheduler < GameScheduler
  include Deviations

  def profile_space
    return [] if invalid_role_partition?
    first_rc, all_other_rcs = subgame_combinations
    deviations = get_deviations
    return first_rc.concat(deviations[roles.first.name]).collect{ |r| format_role(r) } if single_role?
    profs = []
    first_rc.product(*all_other_rcs).each do |prof|
      prof.sort!{|x, y| x[0] <=> y[0]}
      profs << prof.collect {|r| format_role(r)}.join("; ")
    end
    all_other_rcs << first_rc

    deviations.each do |key, value|
      non_deviations = all_other_rcs.select{|val| val[0][0] != key}
      value.product(*non_deviations).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r)}.join("; ")
      end
    end
    profs
  end

  protected

  def add_strategies_to_game(game)
    super
    deviating_roles.each{ |r| r.strategies.each{ |s| game.add_strategy(r.name, s) } }
  end
end