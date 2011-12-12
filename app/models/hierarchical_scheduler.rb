class HierarchicalScheduler < GameScheduler
  field :game_size, type: Integer
  field :agents_per_player, type: Integer
  
  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count*agents_per_player} != game_size || roles.collect{|r| r.strategy_array.size}.min < 1
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
  
  private
  
  def multiply(array)
    ar = []
    array.each {|a| agents_per_player.times{ar << a}}
    ar
  end
end