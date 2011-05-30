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
    profiles.each {|profile| if profile.contains_strategy?(strategy_name); profile.destroy; end}
    strategy_array.delete(strategy_name)
    self.save!
  end
end