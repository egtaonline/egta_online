class SimulatorInitializer
  @queue = :nyx_actions

  def self.perform(simulator_id)
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      Resque::NYX_PROXY.staging_session.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
      Resque::NYX_PROXY.staging_session.scp.upload!(simulator.simulator_source.path, Yetting.deploy_path)
      Resque::NYX_PROXY.staging_session.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
      Resque::NYX_PROXY.staging_session.exec!("cd #{Yetting.deploy_path}; chmod -R ug+rwx #{simulator.fullname}")
    end
  end
end