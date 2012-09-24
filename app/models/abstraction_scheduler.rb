class AbstractionScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple
end