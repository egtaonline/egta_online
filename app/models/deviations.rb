module Deviations
  extend ActiveSupport::Concern

  included do
    embeds_many :deviating_roles, class_name: "Role", as: :role_owner
  end

  def add_role(name, count, reduced_count=count)
    super
    deviating_roles.find_or_create_by(name: name, count: count, reduced_count: reduced_count)
  end

  def remove_role(name)
    super
    deviating_roles.where(name: name).destroy_all
  end

  def add_strategy(role_name, strategy_name)
    role = deviating_roles.where(name: role_name).first
    if !role.strategies.include?(strategy_name)
      role_i = roles.find_or_create_by(name: role_name)
      role_i.strategies << strategy_name
      role_i.strategies.sort!
      role_i.save!
      ProfileAssociater.perform_async(self.id)
    end
  end

  def add_deviating_strategy(role_name, strategy_name)
    role = roles.where(name: role_name).first
    if !role.strategies.include?(strategy_name)
      role_i = deviating_roles.find_or_create_by(name: role_name)
      role_i.strategies << strategy_name
      role_i.strategies.sort!
      role_i.save!
      ProfileAssociater.perform_async(self.id)
    end
  end

  def remove_deviating_strategy(role_name, strategy_name)
    role_i = deviating_roles.where(name: role_name).first
    role_i.strategies.delete(strategy_name)
    self.save
    StrategyRemover.perform_async(self.id)
  end

  def deviating_strategies_for(role_name)
    role = deviating_roles.where(name: role_name).first
    role == nil ? [] : role.strategies
  end

  def available_strategies(role_name)
    super-deviating_strategies_for(role_name)
  end

  private

  def get_deviations
    {}.tap do |deviations|
      deviating_roles.each do |role|
        deviation = role.strategies.product(roles.where(name: role.name).first.strategies.repeated_combination(role.reduced_count-1).to_a)
        deviations[role.name] = deviation.collect {|a| [role.name].concat ([a[0]].push(*a[1]).sort) }
      end
    end
  end
end