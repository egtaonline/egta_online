class StrategyInstancesToSymmetryGroups < Mongoid::Migration
  def self.up
    fcount = 0
    Profile.all.each do |profile|
      if profile["role_instances"] == []
        profile.destroy
      elsif profile["role_instances"] == nil
        profile.destroy
      else
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
        profile.save
        flag = false
        role_strategy_hash = {}
        profile["role_instances"].each{ |role| role_strategy_hash[role["name"]] = role["strategy_instances"] }
        profile.symmetry_groups.each do |symmetry|
          flag ||= !role_strategy_hash[symmetry.role].collect{ |strategy| strategy["name"] }.include?(symmetry.strategy)
          if !flag
            flag ||= role_strategy_hash[symmetry.role].detect{ |strategy| strategy["name"] == symmetry.strategy }["count"] != symmetry.count
          end
        end
        p profile.inspect if flag
      end
    end
  end

  def self.down
  end
end