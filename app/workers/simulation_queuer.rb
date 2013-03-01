class SimulationQueuer
  include Sidekiq::Worker
  sidekiq_options unique: true, queue: 'backend'

  def perform
    prep_service = SimulationPrepService.new
    Simulation.queueable.to_a.each do |simulation|
      prep_service.prepare_simulation(simulation)
      Backend.schedule_simulation(simulation)
    end
  end
end