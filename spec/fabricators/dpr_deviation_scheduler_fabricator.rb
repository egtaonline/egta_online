Fabricator(:dpr_deviation_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  simulator!
  size 4
  process_memory 1000
  samples_per_simulation 1
  default_samples 2
  time_per_sample 40
  configuration {|g| g.simulator.configuration }
end