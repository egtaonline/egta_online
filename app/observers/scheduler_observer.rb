class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    pflag = false
    aflag = false
    if (scheduler.parameter_hash_changed? && scheduler.parameter_hash != nil) || (scheduler["size"] != nil && scheduler.size_changed?)
      scheduler.profiles = []
      pflag = true
    end
    aflag = (scheduler.active_changed? and scheduler.active_was == false) 
    if aflag == false && scheduler.is_a?(GameScheduler)
      aflag = scheduler.max_samples_changed?
    end
    yield
    if pflag && scheduler.is_a?(GameScheduler)
      Resque.enqueue(ProfileAssociater, scheduler.id)
    elsif aflag
      scheduler.profiles.each{|p| Resque.enqueue(ProfileScheduler, p.id)}
    end
  end
end