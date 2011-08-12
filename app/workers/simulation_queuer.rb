class SimulationQueuer
  @queue = :nyx_actions

  def self.perform
    while Simulation.pending.count > 0
      first_sim = Simulation.pending.first
      simulations = Array.new
      first_sim.scheduler.simulations.pending.limit(first_sim.scheduler.jobs_per_request).each do |simulation|
        Resque.enqueue(YAMLCreator, simulation)
        Resque.enqueue(FolderCreator, simulation)
        simulations << simulation.id
      end
      Resque.enqueue(PBSScripter, simulations)
    end
    Resque.enqueue(SimulationQueuer)
  end
end