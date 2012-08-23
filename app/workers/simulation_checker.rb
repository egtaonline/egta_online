class SimulationChecker
#  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    Backend.update_simulations
  end
end
