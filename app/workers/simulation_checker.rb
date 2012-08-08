class SimulationChecker
#  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    Simulation.active.each do |simulation|
      Backend.update_simulation(simulation)
    end
  end
end
