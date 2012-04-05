class HierarchicalDeviationScheduler < DeviationScheduler
  include HierarchicalReduction
  
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
      combinations = role.strategies.repeated_combination(role.count)
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    deviations = {}
    deviating_roles.each do |role|
      deviation = role.strategies.product(roles.where(:name => role.name).first.strategies.repeated_combination(role.count-1).to_a)
      deviations[role.name] = deviation.collect {|a| [role.name].concat ([a[0]].push(*a[1]).sort) }
    end
    profs = []
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      first_ar.concat(deviations[roles.first.name])
      profs = first_ar.collect {|r| format_role(r) }
    else
      first_ar.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r) }.join("; ")
      end
      all_other_ars << first_ar

      deviations.each do |key, value|
        non_deviations = all_other_ars.select{|val| val[0][0] != key}
        value.product(*non_deviations).each do |prof|
          prof.sort!{|x, y| x[0] <=> y[0]}
          profs << prof.collect {|r| format_role(r) }.join("; ")
        end
      end
    end
    profs.uniq
  end
end