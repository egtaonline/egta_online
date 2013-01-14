class StrategyRemover
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    scheduler.remove_self_from_profiles(scheduler.profiles.where(:assignment.nin => scheduler.profile_space))
  end
end