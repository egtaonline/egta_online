class FolderCreator
  @queue = :nyx_actions

  def self.perfom(simulation_id)
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      simulator = simulation.scheduler.simulator
      Resque::NYX_PROXY.staging_session.exec!("mkdir -p #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/features")
      Resque::NYX_PROXY.staging_session.scp.upload!("#{Rails.root}/tmp/temp.yaml", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/simulation_spec.yaml")
      Resque::NYX_PROXY.staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
    end
  end
end