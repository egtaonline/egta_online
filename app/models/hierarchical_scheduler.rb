class HierarchicalScheduler < GameScheduler
  include HierarchicalReduction
  
  field :agents_per_player, type: Integer
  validates_presence_of :agents_per_player
  validate :divisibility
  
  def profile_space
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
      return first_ar.collect {|r| format_role(r)}
    else
      profs = []
      first_ar.to_a.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r)}.join("; ")
      end
    end
    profs
  end
end