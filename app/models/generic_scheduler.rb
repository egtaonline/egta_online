class GenericScheduler < Scheduler
  field :sample_hash, :type => Hash, :default => {}
  
  def required_samples(profile_id)
    val = sample_hash[profile_id.to_s]
    val == nil ? 0 : val
  end
  
  def remove_role(role_name)
    invalid_profiles = self.profiles.where(:proto_string => Regexp.new("#{role_name}: ")).to_a
    invalid_profiles.each {|p| self.sample_hash.delete(p.id.to_s)}
    self.profiles -= invalid_profiles
    self.save
  end

  def remove_strategy(role, strategy_name)
    invalid_profiles = self.profiles.with_role_and_strategy(role, strategy_name).to_a
    invalid_profiles.each {|p| self.sample_hash.delete(p.id.to_s)}
    self.profiles -= invalid_profiles
    self.save
  end
  
  def add_profile(profile_name, sample_count=self["max_samples"])
    proto_string = Profile.convert_to_proto_string(profile_name)
    profile = Profile.find_or_create_by(simulator_id: self.simulator_id,
                                            parameter_hash: self.parameter_hash,
                                            size: Profile.size_of_profile(proto_string),
                                            proto_string: proto_string)
    if profile.valid?
      self.profiles << profile
      sample_hash[profile.id.to_s] = sample_count
      self.save!
      profile.try_scheduling
    end
    profile
  end
end