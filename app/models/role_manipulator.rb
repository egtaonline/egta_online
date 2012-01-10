module RoleManipulator
  def add_role(name, count=nil)
    roles.find_or_create_by(name: name, count: count)
  end

  def remove_role(name)
    roles.where(name: name).destroy_all
  end

  def add_strategy(role, strategy_name)
    role_i = roles.find_or_create_by(name: role)
    role_i.strategies << ::Strategy.find_or_create_by(:name => strategy_name)
    role_i.save!
  end

  def remove_strategy(role, strategy_name)
    role_i = roles.where(name: role).first
    role_i.strategies = role_i.strategies.where(:name.ne => strategy_name)
    role_i.save!
  end

  def unused_strategies(role)
    simulator.roles.where(name: role.name).first.strategy_names-role.strategy_names
  end
end