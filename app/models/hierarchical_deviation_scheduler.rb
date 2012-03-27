class HierarchicalDeviationScheduler < DeviationScheduler
  field :agents_per_player, type: Integer
  validates_presence_of :agents_per_player
  validate :divisibility
  
  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count}*agents_per_player != size || roles.collect{|r| r.strategies.count}.min < 1
      return []
    end
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      combinations = role.strategy_numbers.repeated_combination(role.count)
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    deviations = {}
    deviating_roles.each do |role|
      deviation = role.strategy_names.product(roles.where(:name => role.name).first.strategy_names.repeated_combination(role.count-1).to_a)
      deviations[role.name] = deviation.collect {|a| [role.name].concat ([a[0]].push(*a[1]).sort.collect{|s| ::Strategy.where(:name => s).first.number}) }
    end
    profs = []
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      first_ar.concat(deviations[roles.first.name])
      profs = first_ar.collect {|r| "#{r[0]}: #{multiply(r.drop(1)).join(", ")}"}
    else
      first_ar.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| "#{r[0]}: #{multiply(r.drop(1)).join(", ")}"}.join("; ")
      end
      all_other_ars << first_ar

      deviations.each do |key, value|
        non_deviations = all_other_ars.select{|val| val[0][0] != key}
        value.product(*non_deviations).each do |prof|
          prof.sort!{|x, y| x[0] <=> y[0]}
          profs << prof.collect {|r| "#{r[0]}: #{multiply(r.drop(1)).join(", ")}"}.join("; ")
        end
      end
    end
    profs.uniq
  end
  
  def unassigned_player_count
    size/agents_per_player-roles.reduce(0) {|n, r| n+r.count}
  end
  
  private
  
  def multiply(array)
    ar = []
    array.each {|a| agents_per_player.times{ar << a}}
    ar
  end
  
  def divisibility
    errors.add(:agents_per_player, "does not divide size.") if size % agents_per_player != 0
  end
  
end