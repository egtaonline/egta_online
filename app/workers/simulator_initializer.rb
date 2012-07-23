class SimulatorInitializer
  @queue = :nyx_actions

  def self.perform(simulator_id)
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      Backend.prepare_simulator(simulator)
    end
  end
end