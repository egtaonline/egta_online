Fabricator(:game) do
  simulator!
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  size { 2 }
  configuration { |game| game.simulator.configuration }
end