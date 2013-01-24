class SimulationCleaner
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    Simulation.stale.destroy_all
    Simulation.recently_finished.each {|s| s.requeue}
  end
end