Fabricator(:profile) do
  simulator!
  assignment "All: 2 A"
  configuration { |p| p.simulator.configuration }
end

Fabricator(:sampled_profile, from: :profile) do
  sample_count 1
end

Fabricator(:profile_with_observation, from: :profile) do
  after_create do |profile|
    symmetry_group = profile.symmetry_groups.first
    profile.observations.create(symmetry_groups: [{role: symmetry_group.role, strategy: symmetry_group.strategy, count: 2, players: [{payoff: 100}, {payoff: 200}]}])
  end
end