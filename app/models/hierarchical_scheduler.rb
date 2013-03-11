class HierarchicalScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple

  def profile_space
    return [] if invalid_role_partition?
    reduced_assignments = SubgameCreator.subgame_assignments(roles)
    expanded_assignments = HierarchicalCreator.expand_assignments(reduced_assignments, roles)
    AssignmentFormatter.format_assignments(expanded_assignments.uniq)
  end
end