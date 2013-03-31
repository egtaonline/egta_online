Fabricator(:generic_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  process_memory 1000
  time_per_sample 60
  samples_per_simulation 10
  default_samples 0
  size 2
  simulator_instance!
end

Fabricator(:generic_scheduler_with_roles, from: :generic_scheduler) do
  size 4
  after_create do |scheduler|
    scheduler.add_role("Bidder", 2)
    scheduler.add_role("Seller", 2)
  end
end

Fabricator(:generic_scheduler_with_profiles, from: :generic_scheduler) do
  after_create do |scheduler|
    scheduler.add_role('All', 2)
    scheduler.add_profile("All: 2 A", 5)
  end
end

Fabricator(:generic_scheduler_with_sampled_profiles, from: :generic_scheduler) do
  after_create do |scheduler|
    simulator_instance = scheduler.simulator_instance
    simulator = simulator_instance.simulator
    simulator.add_strategy("All", "A")
    simulator.add_strategy("All", "B")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 2 A")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 1 A, 1 B")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 2 B")
    scheduler.reload.add_role("All", 2)
    scheduler.add_profile("All: 2 A", 5)
    scheduler.reload
  end
end