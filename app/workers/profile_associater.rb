# This class performs the asynchronous assignment of a SymmetricProfile to a Scheduler
# If a matching SymmetricProfile does not already exist, a new one is created
# Scheduler is untyped for a flexibility, since more than one type of scheduler may want to schedule SymmetricProfiles, e.g. a SymmetricDeviationScheduler

class ProfileAssociater
  @queue = :profile_actions

  def self.perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    assignments = new_assignments(scheduler)
    profile_ids = []
    assignments.each do |assignment|
      profile = scheduler.simulator.profiles.find_or_create_by(configuration: scheduler.configuration, assignment: assignment)
      profile_ids << profile.id if profile.valid?
    end
    Profile.where(:_id.in => profile_ids).add_to_set(:scheduler_ids, scheduler.id)
    profile_ids.each { |pid| Resque.enqueue_in(5.minutes, ProfileScheduler, pid) }
  end
  
  def self.new_assignments(scheduler)
    assignments = scheduler.profile_space
    Profile.where(:scheduler_ids => scheduler.id, :assignment.nin => assignments).pull(:scheduler_ids, scheduler.id)
    assignments -= Profile.where(:scheduler_ids => scheduler.id).collect{ |profile| profile.assignment }
  end
end
