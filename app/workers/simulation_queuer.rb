class SimulationQueuer
  @queue = :nyx_actions

  def self.perform(simulation_id)
    simulation = Simulation.pending.find(simulation_id) rescue nil
    if simulation != nil
      Resque.enqueue(YAMLCreator, simulation_id)
      Resque.enqueue(FolderCreator, simulation_id)
      Resque.enqueue(PBSScripter, simulation_id)
    end
  end
end