class ProfileScheduler
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id)
    unless profile.scheduled?
      scheduler = profile.schedulers.with_max_samples
      scheduler.schedule_profile(profile) if scheduler
    end
  end
end