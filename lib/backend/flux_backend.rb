require 'drb/drb'

Dir["#{Rails.root}/lib/backend/flux/*"].each {|file| require file }

class FluxBackend
  attr_accessor :flux_active_limit

  def setup_connections
    @flux_proxy = DRbObject.new_with_uri('druby://localhost:30000')
    @submission_service = SubmissionService.new(@flux_proxy)
    @simulator_prep_service = SimulatorPrepService.new(@flux_proxy)
    @simulation_status_resolver = SimulationStatusResolver.new(@flux_proxy)
    @status_service = SimulationStatusService.new(@flux_proxy)
  end

  def update_simulations
    status = @status_service.get_statuses
    Simulation.active.each do |simulation|
      @simulation_status_resolver.act_on_status(status[simulation.job_id.to_s], simulation)
    end
  end

  def prepare_simulation(simulation, src_dir="#{Rails.root}/tmp/simulations")
    if (flux_count+1 <= flux_active_limit || cac_count > flux_count/6)
      simulation['flux'] = true
      simulation.save
    end
    PbsWrapper.create_wrapper(simulation, src_dir)
  end

  def schedule_simulation(simulation, src_dir="#{Rails.root}/tmp/simulations")
    begin
      response = @flux_proxy.upload!("#{src_dir}/#{simulation.number}", "#{Yetting.deploy_path}/simulations", recursive: true)
      if response == "" || response == nil || response == "\n" || response == "true"
        @submission_service.submit(simulation)
      else
        simulation.fail "could not complete the transfer to remote host.  Speak to Ben to resolve."
      end
    rescue
      simulation.fail "could not complete the transfer to remote host.  Speak to Ben to resolve."
    end
  end

  def prepare_simulator(simulator)
    @simulator_prep_service.cleanup_simulator(simulator)
    begin
      @flux_proxy.upload!(simulator.simulator_source.path, "#{Yetting.deploy_path}/#{simulator.name}.zip", recursive: true)
    rescue
      puts 'failed to upload simulator'
    end
    while @flux_proxy.exec!("[ -f \"filename\" ] && echo \"exists\" || echo \"not exists\"") == "not exists" do
      puts 'missing'
      sleep 1
    end
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