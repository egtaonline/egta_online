Dir["#{Rails.root}/lib/backend/flux/*"].each {|file| require file }

class FluxBackend
  attr_accessor :flux_active_limit
  
  def setup_connections
    puts 'Uniqname: '
    uniqname = gets
    login = Net::SSH.start('flux-login.engin.umich.edu', uniqname)
    @submission_service = SubmissionService.new(login)
    @simulator_prep_service = SimulatorPrepService.new(login)
    transfer = Net::SCP.start('flux-xfer.engin.umich.edu', uniqname)
    @upload_service = UploadService.new(transfer)
    @download_service = DownloadService.new(transfer, 'tmp/data')
    @simulation_status_resolver = SimulationStatusResolver.new(@download_service)
    @status_service = SimulationStatusService.new(login)
  end
  
  def update_simulation(simulation)
    status = @status_service.get_status(simulation)
    @simulation_status_resolver.act_on_status(status, simulation)
  end
  
  def prepare_simulation(simulation, src_dir="#{Rails.root}/tmp/simulations")
    if (flux_count+1 <= flux_active_limit || cac_count > flux_count/6)
      simulation['flux'] = true
      simulation.save
    end
    PbsWrapper.create_wrapper(simulation, src_dir)
  end
  
  def schedule_simulation(simulation, src_dir="#{Rails.root}/tmp/simulations")
    if @upload_service.upload_simulation!(simulation)
      @submission_service.submit(simulation)
    end
  end
  
  def prepare_simulator(simulator)
    @simulator_prep_service.cleanup_simulator(simulator)
    @upload_service.upload_simulator!(simulator)
    @simulator_prep_service.prepare_simulator(simulator)
  end
  
  private
  
  def flux_count
    Simulation.where(active: true, flux: true).count
  end
  
  def cac_count
    Simulation.where(active: true, flux: false).count
  end
end