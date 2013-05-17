class ProfileScheduler
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(profile_id)
    profile = Profile.where(_id: profile_id).without(:symmetry_groups, :observations).first
    unless profile.scheduled?
      scheduler = profile.schedulers.with_max_samples
      scheduler.schedule_profile(profile) if scheduler
    end
  end
end