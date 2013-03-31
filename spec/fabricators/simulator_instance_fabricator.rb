Fabricator(:simulator_instance) do
  simulator!
  configuration { |si| si.simulator.configuration }
end

Fabricator(:simulator_instance_with_profiles, from: :simulator_instance) do
  after_create do |sim|
    sim.simulator.add_strategy("All", "A")
    sim.simulator.add_strategy("All", "B")
    sim.profiles.create(assignment: "All: 2 A")
    sim.profiles.create(assignment: "All: 1 A, 1 B")
    sim.profiles.create(assignment: "All: 2 B")
  end
end