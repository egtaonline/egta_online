class ProfileObserver < Mongoid::Observer
  def before_create(profile)
    total_count = 0
    profile.assignment.each do |role, strategy_hash|
      role_count = 0
      strategy_hash.each do |strategy, count|
        total_count += count
        role_count += count
        profile.symmetry_groups.build(role: role, strategy: strategy, count: count)
      end
      profile["role_#{role}_count"] = role_count
    end
    profile.size = total_count
  end
  
  def before_validation(profile)
    profile.assignment = profile.assignment.fully_sort
  end
end