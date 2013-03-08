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
    role = roles.find_or_create_by(name: role_name)
    add_strategy_to_role(role, strategy_name)
  end

  def add_deviating_strategy(role_name, strategy_name)
    role = deviating_roles.find_or_create_by(name: role_name)
    add_strategy_to_role(role, strategy_name)
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

  def add_strategy_to_role(role, strategy_name)
    unless role.strategies.include?(strategy_name)
      role.strategies << strategy_name
      role.strategies.sort!
      role.save!
      ProfileAssociater.perform_async(self.id)
    end
  end

  def get_deviations
    deviations = {}
    roles.each do |role|
      deviations[role.name] = get_deviations_for_role(role)
    end
    deviations
  end

  def get_deviations_for_role(role)
    deviating_strategies = deviating_roles.find_by(name: role.name).strategies
    deviating_profiles = deviating_strategies.product(partial_role(role, role.reduced_count-1))
    deviating_profiles.collect{ |profile| [role.name].concat(profile.flatten.sort) }
  end

  def partial_role(role, count)
    role.strategies.repeated_combination(count).to_a
  end
end