Fabricator(:generic_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  process_memory 1000
  time_per_sample 60
  samples_per_simulation 10
  simulator!
  parameter_hash {|g| g.simulator.parameter_hash}
end