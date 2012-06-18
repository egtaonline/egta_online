module RoleManipulator
  def add_role(name, count=nil)
    roles.find_or_create_by(name: name, count: count)
  end

  def remove_role(name)
    roles.where(name: name).destroy_all
  end

  def add_strategy(role, strategy_name)
    role_i = roles.find_or_create_by(name: role)
    if strategy_name != nil && !role_i.strategies.include?(strategy_name) 
      role_i.strategies << strategy_name
      role_i.strategies.sort!
      role_i.save!
    end
  end

  def remove_strategy(role, strategy_name)
    role_i = roles.where(name: role).first
    role_i.strategies.delete(strategy_name)
    role_i.save!
  end

  def available_strategies(role)
    simulator.roles.where(name: role.name).first.strategies-role.strategies
  end
  
  def unassigned_player_count
    size-roles.reduce(0) {|n, r| n+r.count}
  end
end