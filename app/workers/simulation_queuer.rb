class SimulationQueuer
#  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    prep_service = SimulationPrepService.new
    prep_service.cleanup
    Simulation.queueable.each do |simulation|
      begin
        prep_service.prepare_simulation(simulation)
        Backend.schedule(simulation)
      rescue
        simulation.error_message = "failed to create files for remote server"
        simulation.failure!
      end
    end
  end
end