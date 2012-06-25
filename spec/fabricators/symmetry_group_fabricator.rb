Fabricator(:symmetry_group) do
  profile
  count 2
  role 'All'
  strategy { Fabricate.sequence(:strategy, 1) { |i| "Strat#{i}" } }
end

Fabricator(:symmetry_group_with_players, from: :symmetry_group) do
  players(count: 2) { |symmetry_group, i| Fabricate(:player) }
end