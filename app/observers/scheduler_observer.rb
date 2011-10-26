class SchedulerObserver < Mongoid::Observer
  def around_update(scheduler)
    puts "I'm checking changes"
    pflag = false
    aflag = false
    if scheduler.parameter_hash_changed? && scheduler.parameter_hash != nil
      puts "found a change"
      scheduler.profile_ids = []
      pflag = true
    end
    if (scheduler.active_changed? and scheduler.active_was == false) or scheduler.max_samples_changed?
      puts "found a different change"
      aflag = true
    end
    yield
    if pflag
      Resque.enqueue(ProfileAssociater, scheduler.id)
    elsif aflag and scheduler.profile_ids != nil
      scheduler.profile_ids.each{|p| Resque.enqueue(ProfileScheduler, p)}
    end
  end
end