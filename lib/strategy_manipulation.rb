module StrategyManipulation
  def add_strategy_by_name(strategy_name)
    strategy_array << strategy_name
    strategy_array.uniq!
    self.save!
    if self.respond_to?("ensure_profiles")
      self.ensure_profiles
    end
  end

  def delete_strategy_by_name(strategy_name)
    if self.is_a? Scheduler or self.is_a? Game
      self.strategy_array.delete(strategy_name)
      self.save!
      if self.is_a? Scheduler
        profile_ids_to_delete =[]
        Profile.find(self.profile_ids).each do |profile|
          if profile.contains_strategy?(strategy_name)
            profile_ids_to_delete << profile.id
          end
        end
        self.update_attribute(:profile_ids, self.profile_ids-profile_ids_to_delete)
      end
    else
      profiles.each {|profile| if profile.contains_strategy?(strategy_name); profile.destroy; end}
      strategy_array.delete(strategy_name)
      self.save!
    end
  end
end