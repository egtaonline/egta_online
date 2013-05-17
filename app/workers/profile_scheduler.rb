class ProfileScheduler
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(profile_id)
    puts Time.now
    puts 'Getting profile'
    profile = Profile.where(_id: profile_id).without(:symmetry_groups, :observations).first
    puts Time.now
    puts 'Got Profile'
    unless profile.scheduled?
      puts Time.now
      puts 'Picking a scheduler'
      scheduler = profile.schedulers.with_max_samples
      puts Time.now
      puts 'Scheduling'
      scheduler.schedule_profile(profile) if scheduler
      puts Time.now
    end
  end
end