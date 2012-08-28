class ProfileScheduler
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id)
    unless profile.scheduled?
      scheduler = Scheduler.scheduling_profile(profile_id).to_a.max{ |x,y| x.required_samples(profile_id)<=>y.required_samples(profile_id) }
      scheduler.schedule_profile(profile) if scheduler
    end
  end
end