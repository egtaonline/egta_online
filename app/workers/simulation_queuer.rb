class SimulationQueuer
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    prep_service = SimulationPrepService.new
    to_be_queued = Simulation.queueable.to_a
    if to_be_queued.size > Simulation.simulation_limit
      to_be_queued = to_be_queued[0..Simulation.simulation_limit]
    end
    puts to_be_queued.size
    puts Time.now
    to_be_queued.each{ |simulation| prep_service.prepare_simulation(simulation) }
    puts Time.now
    sleep 1
    to_be_queued.each{ |simulation| Backend.schedule_simulation(simulation) }
    puts Time.now
  end
end
