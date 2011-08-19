class ProfileScheduler
  @queue = :scheduling

  def self.perform(scheduler_id, profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      if profile.simulations.scheduled.count == 0
        sample_count = profile.simulations.active.scheduled.reduce(0) {|sum, sch| sum+sch.size} + profile.sample_count
        max_schedulable = profile.schedulers.active.collect {|s| s.max_samples}.push(0).max
        if max_schedulable > sample_count
          scheduler = Scheduler.find(scheduler_id) rescue nil
          if scheduler != nil
            num_samples = [scheduler.samples_per_simulation, max_schedulable-sample_count].min
            simulation = profile.simulations.create!(size: num_samples, state: 'pending')
            scheduler.simulations << simulation
            simulation.save!
            Resque.enqueue(SimulationQueuer, simulation.id)
          end
        end
      end
    end
  end
end