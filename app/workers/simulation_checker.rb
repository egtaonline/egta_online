class SimulationChecker
  @queue = :nyx_actions

  def self.perform
    if NYX_PROXY == nil
      NYX_PROXY = ServerProxy.new
      NYX_PROXY.start
    end
    puts "Checking for simulations"
    if Simulation.active.length > 0
      puts "Simulations found"
      simulations = Simulation.active
      output = NYX_PROXY.staging_session.exec!("qstat -a | grep mas-")
      job_id = []
      state_info = []
      if output != nil && output != ""
        outputs = output.split("\n")
        outputs.each do |job|
          job_id << job.split(".").first
          state_info << job.split(/\s+/)
        end
      end
      "Updating status"
      simulations.each {|simulation| Resque.enqueue(SimulationStatusChecker, simulation.id, job_id, state_info) }
    end
    puts "Finishing"
  end
end
