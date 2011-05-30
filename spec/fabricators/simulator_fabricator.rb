Fabricator(:simulator) do
  name "epp_sim"
  version { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  setup { true }
end