class ProfileAssociater
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    pool = ProfileMaker.pool(size: 10)
    new_assignments(scheduler).each do |assignment|
      pool.find_or_create(scheduler, assignment)
    end
  end

  def new_assignments(scheduler)
    assignments = scheduler.profile_space
    scheduler.remove_self_from_profiles(Profile.with_scheduler(scheduler).where(:assignment.nin => assignments))
    assignments -= Profile.with_scheduler(scheduler).collect{ |profile| profile.assignment }
  end
end

class ProfileMaker
  include Celluloid

  def find_or_create(scheduler, assignment)
    scheduler.find_or_create_profile(assignment)
  end
end