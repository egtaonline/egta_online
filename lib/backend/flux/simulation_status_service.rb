class SimulationStatusService
  def initialize(status_connection)
    @status_connection = status_connection
  end

  def get_statuses
    output = @status_connection.exec!("qstat -a | grep egta-")
    parsed_output = {}
    if output != "" && output != nil
      output.split("\n").each{|line| parsed_output[line.split(".").first] = line.split(/\s+/)[9]}
    end
    puts parsed_output
    parsed_output
  end
end