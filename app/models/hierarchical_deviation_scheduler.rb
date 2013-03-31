class HierarchicalDeviationScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple
  include Deviations

  def profile_space
    return [] if invalid_role_partition?
    reduced_assignments = SubgameCreator.subgame_assignments(roles)
    reduced_deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
    expanded_assignments = HierarchicalCreator.expand_assignments(reduced_assignments + reduced_deviation_assignments, roles)
    AssignmentFormatter.format_assignments(expanded_assignments.uniq)
  end
end