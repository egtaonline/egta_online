class ProfileScheduler
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      if profile.simulations.scheduled.count == 0
        sample_count = profile.simulations.active.scheduled.reduce(0) {|sum, sch| sum+sch.size} + profile.sample_count
        max_schedulable = Scheduler.where(profile_ids: profile.id).active.collect {|s| [s.required_samples(profile_id), s]}.push(0).max{|x,y| x[0]<=>y[0]}
        if max_schedulable[0] > sample_count
          scheduler = max_schedulable[1]
          num_samples = [scheduler.samples_per_simulation, max_schedulable[0]-sample_count].min
          simulation = profile.simulations.create!(size: num_samples, state: 'pending', account_id: Account.active.sample.id)
          scheduler.simulations << simulation
          simulation.save!
        end
      end
    end
  end
end