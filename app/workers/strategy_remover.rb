class StrategyRemover
  @queue = :profile_actions
  def self.perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id) rescue nil
    if scheduler != nil
      names = scheduler.profile_space
      scheduler.profiles -= scheduler.profiles.where(:assignment.nin => names)
      scheduler.save
    end
  end
end