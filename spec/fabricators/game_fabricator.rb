Fabricator(:game) do
  simulator!
  name { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  size { 2 }
  parameter_hash {|game| game.simulator.parameter_hash }
  after_create {|sim| if sim.parameter_hash.is_a?(String); sim.update_attribute(:parameter_hash, eval(sim.parameter_hash)); end }
end