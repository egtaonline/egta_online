class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    reset_flag = scheduler.configuration_changed? || scheduler.size_changed?
    scheduler.remove_self_from_profiles(scheduler.profiles) if reset_flag
    schedule_flag = scheduler.active_changed? && scheduler.active
    schedule_flag ||= scheduler.default_samples_changed?
    yield
    if reset_flag && !scheduler.is_a?(GenericScheduler)
      ProfileAssociater.perform_async(scheduler.id)
    elsif schedule_flag
      Profile.with_scheduler(scheduler).each { |profile| profile.try_scheduling }
    end
  end
end