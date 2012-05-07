class StrategyRemover
  @queue = :profile_actions

  def self.perform(scheduler_id, role, strategy)
    scheduler = Scheduler.find(scheduler_id) rescue nil
    if scheduler != nil
      scheduler.profiles -= scheduler.profiles.with_role_and_strategy(role, strategy)
      scheduler.save
    end
  end
end