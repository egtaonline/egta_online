class HierarchicalScheduler < GameScheduler
  field :agents_per_player, type: Integer
  validates_presence_of :agents_per_player
  validate :divisibility
  
  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count*agents_per_player} != size || roles.collect{|r| r.strategy_array.size}.min < 1
      return []
    end
    proto_strings = []
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      if first_ar == nil
        first_ar = role.strategy_array.sort.repeated_combination(role.count).to_a
      else
        all_other_ars << role.strategy_array.sort.repeated_combination(role.count).to_a
      end
    end
    puts first_ar.inspect
    puts all_other_ars.inspect
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategy_array.size} == roles.first.strategy_array.size
      return first_ar.collect {|e| "#{roles.first}: "+ multiply(e).join(", ")}
    else
      ret = []
      first_ar.to_a.product(*all_other_ars).each do |prof|
        count = -1
        ret << roles.collect {|r| count+=1; r.name+": "+multiply(prof[count]).join(", ")}.join("; ")
      end
    end
    ret
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