Fabricator(:symmetric_game) do
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  parameters { Hash["number of agents" => 120] }
  size 2
end