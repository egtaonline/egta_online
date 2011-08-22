class FolderCreator
  @queue = :nyx_actions

  def self.perform(simulation_id)
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      simulator = simulation.scheduler.simulator
      NYX_PROXY.staging_session.exec!("mkdir -p #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/features")
      NYX_PROXY.staging_session.scp.upload!("#{Rails.root}/tmp/temp.yaml", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/simulation_spec.yaml")
      NYX_PROXY.staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
    end
  end
end