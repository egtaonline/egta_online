class HelperDemon

  def self.process_schedulers
    puts "process_schedulers"
    GameScheduler.active.each do |game_scheduler|
      game_scheduler.schedule(30)
    end
    # ProfileScheduler.active.each do |profile_scheduler|
    #   profile_scheduler.schedule
    # end
    # DeviationScheduler.active.each do |deviation_scheduler|
    #   deviation_scheduler.schedule
    # end
  end

  def self.queue_simulations
    puts "queue_simulations"
    proxy = ServerProxy.new
    proxy.queue_pending_simulations
  end

  def self.maintain_simulations
    puts "maintain_simulations"
    proxy = ServerProxy.new
    proxy.check_active_simulations
  end

end