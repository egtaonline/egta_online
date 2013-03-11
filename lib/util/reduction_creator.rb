class ReductionCreator
  def self.expand_assignments(assignments, roles)
    assignments.collect { |assignment| expand_assignment(assignment, roles) }.flatten(1)
  end

  private

  def self.expand_role(strategy_hash, player_count)
    player_multiple = strategy_hash.values.reduce(:+)
    reduction_factor = (player_multiple == 0 || player_multiple == nil) ? 0 : player_count.to_f/player_multiple
    {}.tap do |full_role|
      strategy_hash.each { |strategy, count| full_role[strategy] = count == 0 ? 0 : count * player_count / player_multiple }
      current_count = full_role.values.reduce(:+)
      current_count ||= 0
      while current_count < player_count
        full_role[full_role.max{ |x, y| reduction_factor*strategy_hash[x[0]]-full_role[x[0]] <=> reduction_factor*strategy_hash[y[0]]-full_role[y[0]] }[0]] += 1
        current_count = full_role.values.reduce(:+)
      end
    end
  end

  def self.hasherize(strat_array)
    {}.tap do |strat_hash|
      strat_array.uniq.each { |strat| strat_hash[strat] = strat_array.count(strat) }
    end
  end

  def self.strategy_dehasherize(strategy_hash)
    strategy_array = []
    strategy_hash.each do |strategy, count|
      count.times{ strategy_array << strategy }
    end
    strategy_array.sort
  end
end