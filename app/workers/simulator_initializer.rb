class SimulatorInitializer
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform(simulator_id)
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      Backend.prepare_simulator(simulator)
    end
  end
end