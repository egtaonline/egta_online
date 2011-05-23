class HelperDemon

  def initialize
    @server_proxy = ServerProxy.new
    @server_proxy.start
  end

  def process_schedulers
    puts "process_schedulers"
    Scheduler.active.each do |scheduler|
      scheduler.schedule(30)
    end
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