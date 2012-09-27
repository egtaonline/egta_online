class AbstractionScheduler < Scheduler
  include RoleManipulator::Scheduler
  include SubgameScheduler
  include Sampling::Simple

  def self.fill_role(strat_counts, player_count)
    player_multiple = strat_counts.values.reduce(:+)
    reduction_factor = (player_multiple == 0 || player_multiple == nil) ? 0 : player_count.to_f/player_multiple
    {}.tap do |full_role|
      strat_counts.each { |key, value| full_role[key] = value == 0 ? 0 : value * player_count / player_multiple }
      current_count = full_role.values.reduce(:+)
      current_count ||= 0
      while current_count < player_count
        full_role[full_role.max{ |x, y| reduction_factor*strat_counts[x[0]]-full_role[x[0]] <=> reduction_factor*strat_counts[y[0]]-full_role[y[0]] }[0]] += 1
        current_count = full_role.values.reduce(:+)
      end
    end
  end

  def reduced_game
    return [] if invalid_role_partition?
    first_rc, all_other_rcs = subgame_combinations
    return first_rc.collect { |r| { r[0] => hasherize(r.drop(1)) } } if single_role?
    profs = []
    first_rc.product(*all_other_rcs).each do |prof|
      prof.sort!{|x, y| x[0] <=> y[0]}
      profs << {}.tap do |role_hash|
        prof.each { |r| role_hash[r[0]] = hasherize(r.drop(1)) }
      end
    end
    profs
  end

  private

  def hasherize(strat_array)
    {}.tap do |strat_hash|
      strat_array.uniq.each { |strat| strat_hash[strat] = strat_array.count(strat) }
    end
  end

  def dehasherize(profile)
    profile.collect{ |role, strategy_hash| "#{role}: "+strategy_hash.collect{ |strategy, count| "#{count} #{strategy}" }.join(", ") }.join("; ")
  end
end