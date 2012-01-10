class SimulationCleaner
  @queue = :nyx_actions

  def self.perform
    Simulation.stale.destroy_all
    Simulation.finished.where(:updated_at.gt => (Time.current-86400)).each {|s| s.requeue}
  end
end