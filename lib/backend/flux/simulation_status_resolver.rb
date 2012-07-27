class SimulationStatusResolver
  def initialize(download_service)
    @download_service = download_service
  end
  
  def act_on_status(status, simulation)
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      location = @download_service.download_simulation!(simulation)
      if location
        error_message = check_for_errors(location)
        error_message ? simulation.fail(error_message) : Resque.enqueue(DataParser, simulation.number)
      end
    end
  end
  
  private
  
  def check_for_errors(location)
    File.exists?(location+'/out') ? File.open(location+"/out").read(Yetting.error_store) : 'Files were not found on remote server.'
  end
end