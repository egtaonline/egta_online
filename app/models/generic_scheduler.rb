class GenericScheduler < Scheduler
  field :sample_hash, :type => Hash, :default => {}
  
  def required_samples(profile_id)
    val = sample_hash[profile_id.to_s]
    val == nil ? 0 : val
  end
  
  def add_profile(profile_name, sample_count=self["max_samples"])
    profile = Profile.find_or_create_by(simulator_id: self.simulator_id,
                                            parameter_hash: self.parameter_hash,
                                            size: Profile.size_of_profile(profile_name),
                                            name: profile_name)
    if profile.valid?
      self.profiles << profile
      sample_hash[profile.id.to_s] = sample_count
      self.save!
      profile.try_scheduling
    end
    profile
  end
end