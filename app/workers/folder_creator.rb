class FolderCreator
  @queue = :nyx_actions

  def self.perform(simulation_id)
    @sp ||= ServerProxy.instance
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      puts "creating folder hierarchy for #{simulation.number}"
      simulator = simulation.scheduler.simulator
      @sp.staging_session.exec!("mkdir -p #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/features")
      @sp.staging_session.scp.upload!("#{Rails.root}/tmp/temp.yaml", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/simulation_spec.yaml")
      @sp.staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
      puts "hierarchy completed for #{simulation.number}"
    end
  end
end