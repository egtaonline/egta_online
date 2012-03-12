Fabricator(:profile) do
  simulator!
  proto_string "All: 1, 1"
  parameter_hash {|p| p.simulator.parameter_hash}
  size { 2 }
  before_create do
    if Strategy.where(:number => 1).count == 0
      Fabricate(:strategy, :number => 1)
    end
    nil
  end
  after_create do |sp|
    sp.update_attribute(:parameter_hash, eval(sp.parameter_hash)) if sp.parameter_hash.is_a?(String)
  end
end