class SimulationStatusResolver
  def initialize(flux_proxy, destination="#{Rails.root}/tmp/data")
    @flux_proxy, @destination = flux_proxy, destination
  end
  
  def act_on_status(status, simulation)
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      begin
        @flux_proxy.download!("#{Yetting.deploy_path}/simulations/#{simulation.number}", @destination)
        error_message = check_for_errors("#{@destination}/#{simulation.number}")
        error_message ? simulation.fail(error_message) : Resque.enqueue(DataParser, simulation.number)
      rescue
        simulation.fail "could not complete the transfer from remote host.  Speak to Ben to resolve."
      end
    end
  end
  
  private
  
  def check_for_errors(location)
    File.exists?(location+'/out') ? File.open(location+"/out").read(Yetting.error_store) : 'Files were not found on remote server.'
  end
end