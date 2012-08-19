class GenericScheduler < Scheduler
  include RoleManipulator::RolePartition
  
  field :sample_hash, :type => Hash, :default => {}
  
  def required_samples(profile)
    val = sample_hash[profile.id.to_s]
    val == nil ? 0 : val
  end
  
  def add_role(role_name, count)
    roles.find_or_create_by(name: role_name, count: count)
  end
  
  def remove_role(role_name)
    roles.where(name: role_name).destroy_all
    Profile.where(scheduler_ids: self.id, assignment: Regexp.new("#{role_name}: ")).pull(:scheduler_ids, self.id)
    hash = {}
    Profile.where(scheduler_ids: self.id).each{ |profile| hash[profile.id.to_s] = self.sample_hash[profile.id.to_s] }
    self.update_attribute(:sample_hash, hash)
  end

  def remove_strategy(role, strategy_name)
    Profile.where(scheduler_ids: self.id).with_role_and_strategy(role, strategy_name).pull(:scheduler_ids, self.id)
    hash = {}
    Profile.where(scheduler_ids: self.id).each{ |profile| hash[profile.id.to_s] = self.sample_hash[profile.id.to_s] }
    self.update_attribute(:sample_hash, hash)
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
        profile.schedulers << self
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
    Profile.find(profile_id).pull(:scheduler_ids, self.id)
    hash = {}
    Profile.where(scheduler_ids: self.id).each {|p| hash[p.id.to_s] = self.sample_hash[p.id.to_s]}
    self.sample_hash = hash
    self.save
  end
  
  protected
  
  def add_strategies_to_game(game)
    roles.each do |role|
      game.add_role(role.name, role.count)
      Profile.where(scheduler_id: self.id).collect{ |profile| profile.strategies_for(role.name) }.flatten.uniq.each do |strategy|
        game.add_strategy(role.name, strategy)
      end
    end
  end
end