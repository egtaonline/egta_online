Fabricator(:profile) do
  simulator!
  proto_string "All: 1, 1"
  parameter_hash {|p| p.simulator.parameter_hash}
  size { 2 }
  after_create {|sp| if sp.parameter_hash.is_a?(String); sp.update_attribute(:parameter_hash, eval(sp.parameter_hash)); end }
end