class SimulationChecker
  include Sidekiq::Worker
  sidekiq_options unique: true, queue: 'cluster'

  def perform
    Backend.update_simulations
  end
end
