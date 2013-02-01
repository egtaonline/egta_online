class SimulationStatusResolver
  def initialize(flux_proxy, destination="#{Rails.root}/tmp/data")
    @flux_proxy, @destination = flux_proxy, destination
  end

  def act_on_status(status, simulation_id)
    simulation = Simulation.find(simulation_id) rescue return
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      begin
        @flux_proxy.download!("#{Yetting.simulations_path}/#{simulation_id}", @destination, recursive: true)
        error_message = check_for_errors("#{@destination}/#{simulation_id}")
        error_message ? simulation.fail(error_message) : DataParser.perform_async(simulation_id)
      rescue
        simulation.fail "could not complete the transfer from remote host.  Speak to Ben to resolve."
      end
    end
  end

  private

  def check_for_errors(location)
    File.exists?(location+'/error') ? File.open(location+"/error").read(Yetting.error_store) : 'Files were not found on remote server.'
  end
end