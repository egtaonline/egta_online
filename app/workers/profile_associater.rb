# This class performs the asynchronous assignment of a SymmetricProfile to a Scheduler
# If a matching SymmetricProfile does not already exist, a new one is created
# Scheduler is untyped for a flexibility, since more than one type of scheduler may want to schedule SymmetricProfiles, e.g. a SymmetricDeviationScheduler

class ProfileAssociater
  @queue = :profile_actions

  def self.perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    new_assignments(scheduler).each do |assignment|
      scheduler.find_or_create_profile(assignment)
    end
  end

  def self.new_assignments(scheduler)
    assignments = scheduler.profile_space
    scheduler.remove_self_from_profiles(Profile.with_scheduler(scheduler).where(:assignment.nin => assignments))
    assignments -= Profile.with_scheduler(scheduler).collect{ |profile| profile.assignment }
  end
end
