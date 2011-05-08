class HelperDemon

  def initialize
    @server_proxy = ServerProxy.new("nyx-login.engin.umich.edu", "/home/wellmangroup/many-agent-simulations")
    @server_proxy.start
  end

  def process_schedulers
    puts "process_schedulers"
    Game.all.each do |game|
      game.game_schedulers.active.each do |game_scheduler|
        game_scheduler.schedule(30)
      end
    end
    # ProfileScheduler.active.each do |profile_scheduler|
    #   profile_scheduler.schedule
    # end
    # DeviationScheduler.active.each do |deviation_scheduler|
    #   deviation_scheduler.schedule
    # end
  end

  def queue_simulations
    puts "queue_simulations"
    @server_proxy.queue_pending_simulations
  end

  def maintain_simulations
    puts "maintain_simulations"
    @server_proxy.check_simulations
  end

end