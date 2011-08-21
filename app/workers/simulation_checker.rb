class SimulationChecker
  @queue = :nyx_actions

  def self.perform
    if Simulation.active.length > 0
      simulations = Simulation.active
      output = Resque::NYX_PROXY.staging_session.exec!("qstat -a | grep mas-")
      job_id = []
      state_info = []
      if output != nil && output != ""
        outputs = output.split("\n")
        outputs.each do |job|
          job_id << job.split(".").first
          state_info << job.split(/\s+/)
        end
      end
      simulations.each {|simulation| Resque.enqueue(SimulationStatusChecker, simulation.id, job_id, state_info) }
    end
  end
end
