class GameScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple

  validates_presence_of :size

  def profile_space
    return [] if invalid_role_partition?
    AssignmentFormatter.format_assignments(SubgameCreator.subgame_assignments(roles))
  end
end