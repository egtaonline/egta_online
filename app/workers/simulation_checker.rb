class SimulationChecker
#  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    Simulation.active.each do |simulation|
      Backend.check_simulation(simulation)
    end
  end
end
