class SimulationChecker
  include Sidekiq::Worker
  sidekiq_options unique: true, queue: 'backend'

  def perform
    Backend.update_simulations
  end
end
