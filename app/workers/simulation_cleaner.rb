class SimulationCleaner
  @queue = :profile_actions

  def self.perform
    Simulation.stale.destroy_all
    Simulation.recently_finished.each {|s| s.requeue}
  end
end