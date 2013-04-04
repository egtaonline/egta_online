Fabricator(:symmetry_group) do
  profile
end

Fabricator(:symmetry_group_with_players, from: :symmetry_group) do
  players(count: 2) { |symmetry_group, i| { "p" => 100*(i+1) } }
end