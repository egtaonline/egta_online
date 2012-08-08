class ProfileScheduler
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      unless profile.scheduled?
        puts "called"
        puts Scheduler.scheduling_profile(profile_id).to_a
        scheduler = Scheduler.scheduling_profile(profile_id).to_a.max{ |x,y| x.required_samples(profile_id)<=>y.required_samples(profile_id) }
        puts scheduler.inspect
        scheduler.schedule_profile(profile) if scheduler
      end
    end
  end
end