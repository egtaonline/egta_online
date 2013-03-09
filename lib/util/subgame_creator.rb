class SubgameCreator
  def self.subgame_assignments(roles, formatter=AssignmentFormatter)
    formatter.format_assignments(unformatted_assignments(roles))
  end

  private

  def self.unformatted_assignments(roles)
    role_combinations = roles.collect{ |role| combinations_for_role(role) }
    role_combinations[0].product(*(role_combinations.drop(1)))
  end

  def self.combinations_for_role(role)
    role.strategies.repeated_combination(role.reduced_count).collect{ |c| [role.name].concat(c) }
  end
end