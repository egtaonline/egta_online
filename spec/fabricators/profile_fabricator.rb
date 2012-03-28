Fabricator(:profile) do
  simulator!
  name "All: 2 A"
  parameter_hash {|p| p.simulator.parameter_hash}
  size { 2 }
  after_create do |sp|
    sp.update_attribute(:parameter_hash, eval(sp.parameter_hash)) if sp.parameter_hash.is_a?(String)
  end
end