require 'drb/drb'
require 'backend/flux/pbs_wrapper'
require 'backend/flux/submission_service'
require 'backend/flux/simulator_prep_service'
require 'backend/flux/simulation_status_service'
require 'backend/flux/simulation_status_resolver'

class FluxBackend
  attr_accessor :flux_active_limit, :simulations_path, :flux_simulations_path, :simulators_path

  def setup_connections
    @flux_proxy = DRbObject.new_with_uri('druby://localhost:30000')
    @submission_service = SubmissionService.new(@flux_proxy, @flux_simulations_path)
    @simulator_prep_service = SimulatorPrepService.new(@flux_proxy, @simulators_path)
    @simulation_status_resolver = SimulationStatusResolver.new(@simulations_path)
    @status_service = SimulationStatusService.new(@flux_proxy)
    @pbs_wrapper = PbsWrapper.new(@simulations_path, @flux_simulations_path, @simulators_path)
  end

  def update_simulations
    status = @status_service.get_statuses
    simulations = Simulation.active.only(:job_id).to_a
    simulations.each do |simulation|
      @simulation_status_resolver.act_on_status(status[simulation.job_id.to_s], simulation.id)
    end
  end

  def prepare_simulation(simulation)
    if ( 3*cac_count > flux_count-@flux_active_limit )
      simulation['flux'] = true
      simulation.save
    end
    @pbs_wrapper.create_wrapper(simulation)
    File.chmod(0775, "#{@simulations_path}/#{simulation.id}")
    File.chmod(0775, "#{@simulations_path}/#{simulation.id}/wrapper")
    File.chmod(0775, "#{@simulations_path}/#{simulation.id}/simulation.json")
  end

  def schedule_simulation(simulation)
    if @flux_proxy.exec!("[ -f \"#{@flux_simulations_path}/#{simulation.id}/wrapper\" ] && echo \"exists\" || echo \"not exists\"") == "exists"
      @submission_service.submit(simulation)
    else
      simulation.fail "could not complete the transfer via NFS.  Speak to Ben to resolve."
    end
  end

  def clean_simulation(simulation_number)
    FileUtils.rm_rf "#{@simulations_path}/#{simulation_number}"
  end

  def prepare_simulator(simulator)
    @simulator_prep_service.cleanup_simulator(simulator)
    begin
      @flux_proxy.upload!(simulator.simulator_source.path, "#{@simulators_path}/#{simulator.name}.zip", recursive: true)
    rescue
      puts 'failed to upload simulator'
    end
    while @flux_proxy.exec!("[ -f \"#{@simulators_path}/#{simulator.name}.zip\" ] && echo \"exists\" || echo \"not exists\"") == "not exists" do
      puts 'missing'
      sleep 1
    end
    @simulator_prep_service.prepare_simulator(simulator)
  end

  private

  def flux_count
    Simulation.active.where(flux: true).count
  end

  def cac_count
    Simulation.active.where(flux: false).count
  end
end