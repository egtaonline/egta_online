require_relative "role_combination_generator"

class SubgameCreator
  def self.subgame_assignments(roles)
    role_combinations = roles.collect do |role|
      RoleCombinationGenerator.combinations(role.name, role.strategies, role.reduced_count)
    end
    role_combinations[0].product(*(role_combinations.drop(1)))
  end
end