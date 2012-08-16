class MovingToObservations < Mongoid::Migration
  def self.up
    Profile.where(:sample_count.gt => 0).each do |profile|
      profile.observations.destroy_all
      if profile.symmetry_groups.count == 0
        p profile.id
        if profile["role_instances"] == [] || profile["role_instances"] == nil || profile['sample_records'] == nil || profile['sample_records'] == []
          profile.destroy
          p 'destroy'
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
          profile.features_observations.destroy_all
          profile["sample_records"].each do |sample_record|
            count += 1
            profile.features_observations.create(features: sample_record["features"], observation_id: count)
            profile.symmetry_groups.each do |symmetry_group|
              payoff = sample_record["payoffs"][symmetry_group.role][symmetry_group.strategy]
              symmetry_group.players << 1.upto(symmetry_group.count).collect{ |i| Player.new(payoff: payoff, observation_id: count) }
            end
          end
          profile.save
          flag = false
          profile.symmetry_groups.each do |symmetry_group|
            flag ||= (symmetry_group.payoff.round(5) != (profile["sample_records"].map{ |s| s["payoffs"][symmetry_group.role][symmetry_group.strategy] }.to_scale.mean).round(5))
            if flag
              puts "players #{symmetry_group.players.collect{|player| player.payoff}}"
              puts "sample_records #{profile["sample_records"].collect{ |s| s["payoffs"][symmetry_group.role][symmetry_group.strategy] }}"
            end
          end
          profile.unset("sample_records") unless flag
        end
      else
        observation_ids = profile['symmetry_groups'].collect { |s| s['players'].collect{ |p| p['observation_id'] } }.flatten.uniq
        observation_ids.each do |oid|
          symmetry_groups = profile['symmetry_groups'].collect do |s|
            { role: s['role'], strategy: s['strategy'], count: s['count'], players: s['players'].select{ |p| p['observation_id'] == oid }.collect{ |p| { payoff: p['payoff'], features: p['features'] } } }
          end
          features = profile['features_observations'].select{ |f| f['observation_id'] == oid }.first.features if (profile['features_observations'].try(:count) != nil && profile['features_observations'].count > 0)
          profile.observations.create!(features: features, symmetry_groups: symmetry_groups)
        end
      end
    end
  end

  def self.down
    profile.observations.destroy_all
  end
end