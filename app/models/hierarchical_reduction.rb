module HierarchicalReduction
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
  
  def format_role(role)
    strats = multiply(role.drop(1))
    "#{role[0]}: " + strats.uniq.collect{|s| "#{strats.count(s)} #{s}" }.join(", ")
  end
end