class SimulationQueuer
  @queue = :nyx_queuing

  def self.perform
    prep_service = SimulationPrepService.new
    prep_service.cleanup
    Simulation.queueable.each do |simulation|
      prep_service.prepare_simulation(simulation)
      Backend.schedule_simulation(simulation)
    end
  end
end