Fabricator(:game) do
  simulator_instance!
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  size { 2 }
end