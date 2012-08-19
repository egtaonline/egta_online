class GenericScheduler < Scheduler
  include RoleManipulator::RolePartition
  
  field :sample_hash, :type => Hash, :default => {}
  
  def required_samples(profile_id)
    val = sample_hash[profile_id.to_s]
    val == nil ? 0 : val
  end
  
  def add_role(role_name, count)
    roles.find_or_create_by(name: role_name, count: count)
  end
  
  def remove_role(role_name)
    roles.where(name: role_name).destroy_all
    invalid_profiles = self.profiles.where(assignment: Regexp.new("#{role_name}: ")).to_a
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
  
  def add_profile(assignment, sample_count=self["default_samples"])
    assignment = assignment.assignment_sort
    profile = simulator.profiles.find_or_create_by(configuration: self.configuration,
                                                   assignment: assignment)
    if profile.valid?
      flag = profile.size == self.size
      roles.each do |r|
        flag &&= profile.symmetry_groups.where(role: r.name).collect{ |s| s.count }.reduce(:+) == r.count
      end
      if flag
        self.profiles << profile
        sample_hash[profile.id.to_s] = sample_count
        self.save!
        profile.try_scheduling
      else
        profile.errors.add(:assignment, "cannot be scheduled by this scheduler due to mismatch on role partition.")
      end
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
  
  protected
  
  def add_strategies_to_game(game)
    roles.each do |role|
      game.add_role(role.name, role.count)
      profiles.collect{ |profile| profile.strategies_for(role.name) }.flatten.uniq.each do |strategy|
        game.add_strategy(role.name, strategy)
      end
    end
  end
end