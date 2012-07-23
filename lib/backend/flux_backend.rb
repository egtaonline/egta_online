Dir["#{Rails.root}/lib/backend/flux/*"].each {|file| require file }

class FluxBackend
  attr_accessor :flux_active_limit
  
  def setup_connections
    puts 'Uniqname: '
    uniqname = gets
    login = Net::SSH.start('flux-login.engin.umich.edu', uniqname)
    @submission_service = SubmissionService.new(login)
    @simulator_prep_service = SimulatorPrepService.new(login)
    @transfer_service = TransferService.new(Net::SCP.start('flux-xfer.engin.umich.edu', uniqname))
  end
  
  def prepare_simulation(simulation, src_dir="#{Rails.root}/tmp/simulations")
    if (flux_count+1 <= flux_active_limit || cac_count > flux_count/6)
      simulation['flux'] = true
      simulation.save
    end
    PbsWrapper.create_wrapper(simulation, src_dir)
  end
  
  def schedule(simulation, src_dir="#{Rails.root}/tmp/simulations")
    if @transfer_service.upload_simulation!(simulation)
      @submission_service.submit(simulation)
    end
  end
  
  def prepare_simulator(simulator)
    @simulator_prep_service.cleanup_simulator(simulator)
    @transfer_service.upload_simulator!(simulator)
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