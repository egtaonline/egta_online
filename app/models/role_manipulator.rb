module RoleManipulator
  def add_role(name, count=nil)
    roles.find_or_create_by(name: name, count: count)
  end

  def remove_role(name)
    roles.where(name: name).destroy_all
  end

  def add_strategy(role, strategy)
    role_i = roles.find_or_create_by(name: role)
    role_i.strategy_array << strategy
    role_i.save!
  end

  def remove_strategy(role, strategy)
    role_i = roles.where(name: role).first
    role_i.strategy_array.delete(strategy)
    role_i.save!
  end
end