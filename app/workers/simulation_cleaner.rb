class SimulationCleaner
  @queue = :nyx_actions

  def self.perform
    puts "Cleaning simulations"
    Simulation.stale.destroy_all
  end
end