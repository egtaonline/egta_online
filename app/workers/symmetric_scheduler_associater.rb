class SymmetricSchedulerAssociater
  @queue = :profile_actions

  def self.perform(scheduler_id, proto_string)
    scheduler = Scheduler.find(scheduler_id) rescue nil
    if scheduler != nil
      profile = SymmetricProfile.find_or_create_by(simulator_id: scheduler.simulator_id,
                                                  parameter_hash: scheduler.parameter_hash,
                                                  proto_string: proto_string)
      profile.schedulers << scheduler
      scheduler.save!
      Resque.enqueue(ProfileScheduler, scheduler_id, profile.id)
    end
  end
end