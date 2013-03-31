Fabricator(:profile) do
  simulator_instance!
  assignment "All: 2 A"
end

Fabricator(:sampled_profile, from: :profile) do
  sample_count 1
end

Fabricator(:profile_with_observation, from: :profile) do
  after_create do |profile|
    observation = profile.symmetry_groups.collect{ |sgroup| { role: sgroup.role, strategy: sgroup.strategy, count: sgroup.count, players: Array.new(sgroup.count){ |i| { payoff: (i+1)*100 } } } }
    profile.observations.create(symmetry_groups: observation)
  end
end