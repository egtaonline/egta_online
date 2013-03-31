class DeviationScheduler < GameScheduler
  include Deviations

  def profile_space
    return [] if invalid_role_partition?
    subgame_assignments = SubgameCreator.subgame_assignments(roles)
    deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
    AssignmentFormatter.format_assignments((subgame_assignments+deviation_assignments).uniq)
  end
end