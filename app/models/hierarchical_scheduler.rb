class HierarchicalScheduler < GameScheduler
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
      combinations = role.strategies.repeated_combination(role.count).to_a
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      return first_ar.collect {|r| "#{r[0]}: #{multiply(r.drop(1)).join(", ")}"}
    else
      profs = []
      first_ar.to_a.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| "#{r[0]}: #{multiply(r.drop(1)).join(", ")}"}.join("; ")
      end
    end
    profs
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