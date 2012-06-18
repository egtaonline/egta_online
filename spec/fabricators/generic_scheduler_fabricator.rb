Fabricator(:generic_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  process_memory 1000
  time_per_sample 60
  samples_per_simulation 10
  default_samples 0
  size 2
  simulator!
  configuration {|g| g.simulator.configuration}
end

Fabricator(:generic_scheduler_with_profiles, from: :generic_scheduler) do
  after_create do |scheduler| 
    scheduler.add_role('All', 2)
    scheduler.add_profile("All: 2 A", 5)
  end
end