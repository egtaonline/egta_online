class StrategyRemover
  @queue = :profile_actions
  def self.perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id) rescue nil
    if scheduler != nil
      names = scheduler.profile_space
      Profile.where(:scheduler_ids => scheduler.id, :assignment.nin => names).pull(:scheduler_ids, scheduler.id)
    end
  end
end