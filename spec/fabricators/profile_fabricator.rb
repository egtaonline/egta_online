Fabricator(:profile) do
  proto_string { "All: [A, A]" }
  parameter_hash { Hash[:a => "2"]}
  after_create {|sp| if sp.parameter_hash.is_a?(String); sp.update_attribute(:parameter_hash, eval(sp.parameter_hash)); end }
end