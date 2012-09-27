module SubgameScheduler
  private

  def format_role(role)
    strats = role.drop(1)
    "#{role[0]}: " + strats.uniq.collect{|s| "#{strats.count(s)} #{s}" }.join(", ")
  end

  def single_role?
    (roles.size == 1) | (roles.map{ |r| r.strategies.count }.reduce(:+) == roles.first.strategies.count)
  end

  def subgame_combinations
    rcs = roles.collect{ |role| role.strategies.repeated_combination(role.reduced_count).collect{|c| [role.name].concat(c) } }
    return rcs[0], rcs.drop(1)
  end
end