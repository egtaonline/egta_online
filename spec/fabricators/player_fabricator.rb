Fabricator(:player) do
  symmetry_group
  payoff { rand(100) }
end