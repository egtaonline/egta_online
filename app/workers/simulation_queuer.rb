class SimulationQueuer
  @queue = :nyx_actions

  def self.perform(simulation_id)
    simulation = Simulation.pending.find(simulation_id) rescue nil
    if simulation != nil
      Resque.enqueue(YAMLCreator, simulation)
      Resque.enqueue(FolderCreator, simulation)
      Resque.enqueue(PBSScripter, simulation)
    end
  end
end