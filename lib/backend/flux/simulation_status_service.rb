class SimulationStatusService
  def initialize(status_connection)
    @status_connection = status_connection
  end
  
  def get_status(simulation)
    output = @status_connection.exec!("qstat -a | grep #{simulation.job_id} | grep egta-")
    if output != "" && output != nil
      output.split(/\s+/)[9]
    else
      output
    end
  end
end