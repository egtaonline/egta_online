class SimulationStatusResolver
  ERROR_LIMIT = 1024

  def initialize(simulations_path)
    @simulations_path = simulations_path
  end

  def act_on_status(status, simulation_id)
    simulation = Simulation.find(simulation_id) rescue return
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      error_message = check_for_errors("#{@simulations_path}/#{simulation_id}")
      error_message ? simulation.fail(error_message) : DataParser.perform_async(simulation_id)
    end
  end

  private

  def check_for_errors(location)
    File.exists?(location+'/error') ? File.open(location+"/error").read(ERROR_LIMIT) : 'Files were not found on remote server.'
  end
end