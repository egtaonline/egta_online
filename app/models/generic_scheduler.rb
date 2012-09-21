class GenericScheduler < Scheduler
  include RoleManipulator::RolePartition

  field :sample_hash, type: Hash, default: {}

  def required_samples(profile)
    val = sample_hash[profile.id.to_s]
    val ? val : 0
  end

  def add_role(role_name, count)
    roles.find_or_create_by(name: role_name, count: count)
  end

  def remove_role(role_name)
    roles.where(name: role_name).destroy_all
    remove_self_from_profiles(Profile.with_scheduler(self).with_role(role_name))
  end

  def remove_strategy(role, strategy_name)
    remove_self_from_profiles(Profile.with_scheduler(self).with_role_and_strategy(role, strategy_name))
  end

  def add_profile(assignment, sample_count=self["default_samples"])
    logger.warn "#{Time.now} sorting"
    assignment = assignment.assignment_sort
    logger.warn "#{Time.now} creating"
    profile = Profile.find_or_create_by(simulator_id: self.simulator_id, configuration: self.configuration,
                                                   assignment: assignment)
    logger.warn profile.inspect
    logger.warn "#{Time.now} checking validity"
    if profile.errors.messages.empty?
      logger.warn "#{Time.now} testing validity"
      flag = profile.size == self.size
      roles.each do |r|
        flag &&= profile.symmetry_groups.where(role: r.name).collect{ |s| s.count }.reduce(:+) == r.count
      end
      logger.warn "#{Time.now} still testing validity"
      if flag
        logger.warn "#{Time.now} valid, adding scheduler"
        profile.schedulers << self
        logger.warn "#{Time.now} updating sample_hash"
        sample_hash[profile.id.to_s] = sample_count
        logger.warn "#{Time.now} saving"
        self.save!
        logger.warn "#{Time.now} finish"
        profile.try_scheduling
      else
        profile.errors.add(:assignment, "cannot be scheduled by this scheduler due to mismatch on role partition.")
      end
    end
    profile
  end

  def remove_profile(profile_id)
    remove_self_from_profiles(Profile.where(_id: profile_id))
  end

  def remove_self_from_profiles(profiles_to_remove)
    if profiles_to_remove.count != 0
      super
      hash = {}
      profiles.each{ |profile| hash[profile.id.to_s] = self.sample_hash[profile.id.to_s] }
      self.update_attribute(:sample_hash, hash)
    end
  end

  protected

  def add_strategies_to_game(game)
    roles.each do |role|
      game.add_role(role.name, role.count)
      Profile.with_scheduler(self).collect{ |profile| profile.strategies_for(role.name) }.flatten.uniq.each do |strategy|
        game.add_strategy(role.name, strategy)
      end
    end
  end
end