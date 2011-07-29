Fabricator(:game) do
  simulator_id { Simulator.last.id }
  name { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  size { 2 }
  after_create {|sim| if sim.parameter_hash.is_a?(String); sim.update_attribute(:parameter_hash, eval(sim.parameter_hash)); end }
end