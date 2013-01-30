class SimulationCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform(simulation_number)
    Backend.clean_simulation(simulation_number)
  end
end