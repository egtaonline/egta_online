Fabricator(:api_scheduler) do
  name "generic"
  process_memory 1000
  time_per_sample 60
  samples_per_simulation 10
  max_samples 10
  simulator!
  parameter_hash {|g| g.simulator.parameter_hash}
end