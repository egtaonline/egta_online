Fabricator(:simulator) do
  name "epp_sim"
  version { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  setup { true }
  after_create do |sim|
    sim.run_time_configurations << Fabricate(:run_time_configuration)
    gs = Fabricate(:game_scheduler, :simulator_id => sim.id)
  end
end