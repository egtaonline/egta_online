Fabricator(:simulator) do
  name "epp_sim"
  version { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  setup { true }
  parameter_hash { Hash[:a => "2"] }
  after_create {|sim| if sim.parameter_hash.is_a?(String); sim.update_attribute(:parameter_hash, eval(sim.parameter_hash)); end }
  strategy_array { Array["strategy#{sequence(:strategy_array)}", "strategy#{sequence(:strategy_array)}"]}
end