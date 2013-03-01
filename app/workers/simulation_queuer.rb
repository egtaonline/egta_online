class SimulationQueuer
  include Sidekiq::Worker
  sidekiq_options unique: true, queue: 'backend'

  def perform
    prep_service = SimulationPrepService.new
    to_be_queued = Simulation.queueable.to_a
    to_be_queued.each{ |simulation| prep_service.prepare_simulation(simulation) }
    sleep 1
    to_be_queued.each{ |simulation| Backend.schedule_simulation(simulation) }
  end
end