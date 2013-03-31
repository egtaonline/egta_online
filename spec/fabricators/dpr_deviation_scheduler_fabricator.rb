Fabricator(:dpr_deviation_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  simulator_instance!
  size 4
  process_memory 1000
  samples_per_simulation 1
  default_samples 2
  time_per_sample 40
end

Fabricator(:dpr_deviation_scheduler_with_profiles, from: :dpr_deviation_scheduler) do
  after_create do |scheduler|
    scheduler.add_role("All", 120, 2)
    scheduler.add_strategy("All", "A")
    scheduler.add_deviating_strategy("All", "B")
  end
end

Fabricator(:dpr_deviation_scheduler_with_sampled_profiles, from: :dpr_deviation_scheduler) do
  after_create do |scheduler|
    simulator_instance = scheduler.simulator_instance
    simulator = simulator_instance.simulator
    simulator.add_strategy("All", "A")
    simulator.add_strategy("All", "B")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 2 A")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 1 A, 1 B")
    Fabricate(:profile_with_observation, simulator_instance: simulator_instance, assignment: "All: 2 B")
    scheduler.reload.add_role("All", 2)
    scheduler.add_strategy("All", "A")
    scheduler.add_deviating_strategy("All", "B")
    scheduler.reload
  end
end