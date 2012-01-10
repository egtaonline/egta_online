class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    pflag = false
    aflag = false
    if scheduler.parameter_hash_changed? && scheduler.parameter_hash != nil
      scheduler.profile_ids = []
      pflag = true
    end
    aflag = (scheduler.active_changed? and scheduler.active_was == false) || scheduler.max_samples_changed?
    yield
    if pflag
      Resque.enqueue(ProfileAssociater, scheduler.id)
    elsif aflag and scheduler.profile_ids != nil
      scheduler.profile_ids.each{|p| Resque.enqueue(ProfileScheduler, p)}
    end
  end
end