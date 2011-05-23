Fabricator(:simulator) do
  name "epp_sim"
  version { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  simulator_source { double("simulator_source"); simulator_source.stub(:path) {"/path"} }
end