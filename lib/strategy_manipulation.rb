module StrategyManipulation
  def add_strategy_by_name(strategy_name)
    strategy_array << strategy_name
    strategy_array.uniq!
    self.save!
    if self.respond_to?("add_profiles_from_strategy")
      self.add_profiles_from_strategy(strategy_name)
    elsif self.respond_to?("ensure_profiles")
      self.ensure_profiles
    end
  end

  def delete_strategy_by_name(strategy_name)
    if self.respond_to?("ensure_profiles")
      strategy_array.delete(strategy_name)
      profile_ids_to_delete =[]
      self.profiles.each do |profile|
        if profile.contains_strategy?(strategy_name)
          profile.schedulers.delete(self)
          profile.save!
          profile_ids_to_delete << profile.id
        end
      end
      self.update_attribute(:profile_ids, self.profile_ids-profile_ids_to_delete)
    else
      profiles.each {|profile| if profile.contains_strategy?(strategy_name); profile.destroy; end}
      strategy_array.delete(strategy_name)
      self.save!
    end
  end
end