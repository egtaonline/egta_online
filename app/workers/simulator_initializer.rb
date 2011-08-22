class SimulatorInitializer
  @queue = :nyx_actions

  def self.perform(simulator_id)
    @sp ||= ServerProxy.instance
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      @sp.staging_session.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
      @sp.staging_session.scp.upload!(simulator.simulator_source.path, Yetting.deploy_path)
      @sp.staging_session.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
      @sp.staging_session.exec!("cd #{Yetting.deploy_path}; chmod -R ug+rwx #{simulator.fullname}")
    end
  end
end