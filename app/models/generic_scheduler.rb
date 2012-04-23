class GenericScheduler < Scheduler
  field :sample_hash, :type => Hash, :default => {}
  
  def required_samples(profile_id)
    val = sample_hash[profile_id.to_s]
    val == nil ? 0 : val
  end
  
  def remove_role(role_name)
    invalid_profiles = self.profiles.where(:name => Regexp.new("#{role_name}: ")).to_a
    self.profiles -= invalid_profiles
    hash = {}
    self.profile_ids.each {|p_id| hash[p_id.to_s] = self.sample_hash[p_id.to_s]}
    self.sample_hash = hash
    self.save
  end

  def remove_strategy(role, strategy_name)
    invalid_profiles = self.profiles.with_role_and_strategy(role, strategy_name).to_a
    self.profiles -= invalid_profiles
    hash = {}
    self.profile_ids.each {|p_id| hash[p_id.to_s] = self.sample_hash[p_id.to_s]}
    self.sample_hash = hash
    self.save
  end
  
  def add_profile(profile_name, sample_count=self["max_samples"])
    profile = Profile.find_or_create_by(simulator_id: self.simulator_id,
                                            parameter_hash: self.parameter_hash,
                                            name: profile_name)
    if profile.valid?
      self.profiles << profile
      sample_hash[profile.id.to_s] = sample_count
      self.save!
      profile.try_scheduling
    end
    profile
  end
  
  def remove_profile(profile_id)
    self.profiles = self.profiles.where(:_id.ne => profile_id)
    hash = {}
    self.profile_ids.each {|p_id| hash[p_id.to_s] = self.sample_hash[p_id.to_s]}
    self.sample_hash = hash
    self.save
  end
end