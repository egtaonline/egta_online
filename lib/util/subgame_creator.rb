class SubgameCreator
  def self.subgame_combinations(roles)
    role_combinations = combinations_for_roles(roles)
    return role_combinations[0] if role_combinations.size == 1
    role_combinations[0].product(*(role_combinations.drop(1))).collect{ |rc| rc.join('; ') }
  end

  private

  def self.combinations_for_roles(roles)
    roles.collect{ |role| combinations_for_role(role) }
  end

  def self.combinations_for_role(role)
    combinations = role.strategies.repeated_combination(role.reduced_count).collect{ |c| [role.name].concat(c) }
    combinations.collect{ |combination| AssignmentFormatter.format_role_combination(combination) }
  end
end