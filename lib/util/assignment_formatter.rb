class AssignmentFormatter
  def self.format_role_combination(role_combination)
    strats = role_combination.drop(1)
    "#{role_combination[0]}: " + strats.uniq.collect{ |s| "#{strats.count(s)} #{s}" }.join(", ")
  end
end