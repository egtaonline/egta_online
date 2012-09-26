module HierarchicalReduction

  private

  def arrays_to_cross
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      combinations = role.strategies.repeated_combination(role.reduced_count).to_a
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    return first_ar, all_other_ars
  end

  def format_role(role, multiple)
    strats = role.drop(1)
    "#{role[0]}: " + strats.uniq.collect{|s| "#{strats.count(s)*multiple} #{s}" }.join(", ")
  end
end