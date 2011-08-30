class DirtyExitCleaner
  @queue = :profile_actions

  def self.perform
    puts "ensuring profiles that are due for more simulations get them"
    Simulation.finished.where(:updated_at.gt => (Time.current-3600)).each {|s| s.requeue}
  end
end