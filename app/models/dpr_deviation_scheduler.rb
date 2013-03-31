class DprDeviationScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple
  include Deviations

  def add_role(name, count, reduced_count=count)
    super
    deviating_roles.find_or_create_by(name: name, count: count, reduced_count: reduced_count)
  end

  def profile_space
    return [] if invalid_role_partition?
    reduced_assignments = SubgameCreator.subgame_assignments(roles)
    reduced_deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
    expanded_assignments = DprCreator.expand_assignments(reduced_assignments + reduced_deviation_assignments, roles)
    AssignmentFormatter.format_assignments(expanded_assignments.uniq)
  end
end