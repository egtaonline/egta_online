class DeviationScheduler < GameScheduler
  include SubgameScheduler
  include Deviations

  def profile_space
    return [] if invalid_role_partition?
    subgame_assignments = SubgameCreator.subgame_assignments(roles)
    deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
    AssignmentFormatter.format_assignments((subgame_assignments+deviation_assignments).uniq)
  end

  protected

  def add_strategies_to_game(game)
    super
    deviating_roles.each{ |r| r.strategies.each{ |s| game.add_strategy(r.name, s) } }
  end
end