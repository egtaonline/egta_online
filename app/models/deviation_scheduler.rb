class DeviationScheduler < GameScheduler
  embeds_many :deviating_roles, :class_name => "Role", :as => :role_owner
  
  def add_role(name, count=nil)
    super
    deviating_roles.find_or_create_by(name: name, count: count)
  end
  
  def remove_role(name)
    super
    deviating_roles.where(name: name).destroy_all
  end
  
  def add_deviating_strategy(role_name, strategy_name)
    role_i = deviating_roles.find_or_create_by(name: role_name)
    role_i.strategies << strategy_name
    role_i.strategies.sort!
    role_i.save!
    Resque.enqueue(ProfileAssociater, self.id)
  end
  
  def remove_deviating_strategy(role, strategy_name)
    role_i = deviating_roles.where(name: role).first
    role_i.strategies.delete(strategy_name)
    role_i.save!
    self.save
    Resque.enqueue(StrategyRemover, self.id)
  end
  
  def unused_strategies(role)
    deviating_role = deviating_roles.where(:name => role.name).first
    simulator.roles.where(name: role.name).first.strategies-role.strategies-(deviating_role == nil ? [] : deviating_role.strategies)
  end
  
  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count} != size || roles.collect{|r| r.strategies.count}.min < 1
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
      profs = first_ar.collect {|r| format_role(r)}
    else
      first_ar.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r)}.join("; ")
      end
      all_other_ars << first_ar

      deviations.each do |key, value|
        non_deviations = all_other_ars.select{|val| val[0][0] != key}
        value.product(*non_deviations).each do |prof|
          prof.sort!{|x, y| x[0] <=> y[0]}
          profs << prof.collect {|r| format_role(r)}.join("; ")
        end
      end
    end
    profs
  end
end