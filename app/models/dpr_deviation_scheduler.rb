class DprDeviationScheduler < AbstractionScheduler
  include Deviations

  def add_role(name, count, reduced_count)
    super
    deviating_roles.find_or_create_by(name: name, count: count, reduced_count: reduced_count)
  end
end