class SimulationChecker
  @queue = :nyx_queuing

  def self.perform
    Backend.update_simulations
  end
end
