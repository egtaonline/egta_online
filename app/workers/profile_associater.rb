# This class performs the asynchronous assignment of a SymmetricProfile to a Scheduler
# If a matching SymmetricProfile does not already exist, a new one is created
# Scheduler is untyped for a flexibility, since more than one type of scheduler may want to schedule SymmetricProfiles, e.g. a SymmetricDeviationScheduler

class ProfileAssociater
  @queue = :profile_actions

  def self.perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id) rescue nil
    if scheduler != nil
      proto_strings = scheduler.ensure_profiles
      profile_ids = []
      proto_strings.each do |proto_string|
        profile = Profile.find_or_create_by(simulator_id: scheduler.simulator_id,
                                                parameter_hash: scheduler.parameter_hash,
                                                size: scheduler.size,
                                                proto_string: proto_string)
        profile.try_scheduling
        profile_ids << profile.id
      end
      scheduler.update_attribute(:profile_ids, profile_ids)
    end
  end
end
