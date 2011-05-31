Fabricator(:scheduler, :class_name => :game_scheduler) do
  size 2
  process_memory 1000
  jobs_per_request 1
  samples_per_simulation 1
  max_samples 2
  time_per_sample 40
end