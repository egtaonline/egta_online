Fabricator(:profile) do
  simulator!
  assignment "All: 2 A"
  configuration { |p| p.simulator.configuration }
end

Fabricator(:sampled_profile, from: :profile) do
  sample_count 1
end