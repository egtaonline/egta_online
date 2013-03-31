class ProfileObserver < Mongoid::Observer
  def before_create(profile)
    total_count = 0
    profile.assignment.split("; ").each do |role|
      role_count = 0
      role.split(": ")[1].split(", ").each do |strategy|
        count = strategy.split(" ")[0].to_i
        total_count += count
        role_count += count
        profile.symmetry_groups.build(role: role.split(": ")[0], strategy: strategy.split[1], count: count)
      end
      profile["role_#{role.split(": ")[0]}_count"] = role_count
    end
    profile.size = total_count
  end

  def before_validation(profile)
    profile.assignment = profile.assignment.assignment_sort
  end
end