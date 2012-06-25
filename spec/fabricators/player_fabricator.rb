Fabricator(:player) do
  symmetry_group
  observation_id 1
  payoff { rand(100) }
end