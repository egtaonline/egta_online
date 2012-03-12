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
    role_i.strategies << ::Strategy.find_or_create_by(:name => strategy_name)
    role_i.save!
  end
  
  def remove_deviating_strategy(role, strategy_name)
    role_i = deviating_roles.where(name: role).first
    role_i.strategies = role_i.strategies.where(:name.ne => strategy_name)
    role_i.save!
  end
  
  def unused_strategies(role)
    deviating_role = deviating_roles.where(:name => role.name).first
    simulator.roles.where(name: role.name).first.strategy_names-role.strategy_names-(deviating_role == nil ? [] : deviating_role.strategy_names)
  end
end