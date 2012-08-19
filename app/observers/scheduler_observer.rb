class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    reset_flag = scheduler.configuration_changed? || scheduler.size_changed?
    Profile.where(scheduler_ids: scheduler.id).pull(:scheduler_ids, scheduler.id) if reset_flag
    schedule_flag = scheduler.active_changed? && scheduler.active
    schedule_flag ||= scheduler.is_a?(GameScheduler) && scheduler.default_samples_changed?
    yield
    if reset_flag && scheduler.is_a?(GameScheduler)
      Resque.enqueue(ProfileAssociater, scheduler.id)
    elsif schedule_flag
      Profile.where(:scheduler_ids => scheduler.id).each { |profile| profile.try_scheduling }
    end
  end
end