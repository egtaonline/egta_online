class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    reset_flag = scheduler.configuration_changed? || scheduler.size_changed?
    scheduler.profiles = [] if reset_flag
    schedule_flag = scheduler.active_changed? && !scheduler.active_was 
    schedule_flag ||= scheduler.is_a?(GameScheduler) && scheduler.max_samples_changed?
    yield
    if reset_flag && scheduler.is_a?(GameScheduler)
      Resque.enqueue(ProfileAssociater, scheduler.id)
    elsif schedule_flag
      scheduler.profiles.each{|p| Resque.enqueue(ProfileScheduler, p.id)}
    end
  end
end