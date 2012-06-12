Fabricator(:profile) do
  simulator!
  assignment "All: 2 A"
  configuration { |p| p.simulator.configuration }
end