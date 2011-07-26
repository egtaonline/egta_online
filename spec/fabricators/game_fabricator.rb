Fabricator(:game) do
  simulator_id { Simulator.last.id }
  name { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  size { 2 }
end