object @object

attribute :id

case @granularity
when "summary"
  attribute :sample_count
  child :symmetry_groups do |profile|
    extends "api/v3/profiles/symmetry_group"
  end
when "observation"
  node :observations do |profile|
    1.upto(profile.sample_count).collect do |i|
      { symmetry_groups: profile.symmetry_groups.collect { |symmetry_group| {role: symmetry_group.role, strategy: symmetry_group.strategy, count: symmetry_group.count, payoff: symmetry_group.payoff_for(i) } } }
    end
  end
when "full"
  node :observations do |profile|
    1.upto(profile.sample_count).collect do |i|
      { symmetry_groups: profile.symmetry_groups.collect do |symmetry_group|
          { role: symmetry_group.role, strategy: symmetry_group.strategy, players: symmetry_group.players.where(observation_id: i).collect{ |player| { payoff: player.payoff, features: player.features } } }
        end
      }
    end
  end
end