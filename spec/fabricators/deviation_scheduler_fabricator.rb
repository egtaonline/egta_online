Fabricator(:deviation_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  simulator!
  size 2
  process_memory 1000
  samples_per_simulation 1
  default_samples 2
  time_per_sample 40
  configuration {|g| g.simulator.configuration }
end

Fabricator(:deviation_scheduler_with_profiles, from: :deviation_scheduler) do
  after_create do |scheduler|
    scheduler.add_role("All", scheduler.size)
    scheduler.add_strategy("All", "A")
    scheduler.add_deviating_strategy("All", "B")
    scheduler.reload
  end
end