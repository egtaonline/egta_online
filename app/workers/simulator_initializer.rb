class SimulatorInitializer
  @queue = :nyx_actions

  def self.perform(simulator_id)
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      LOGIN_CONNECTION.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
      TRANSFER_CONNECTION.upload!(simulator.simulator_source.path, "#{Yetting.deploy_path}/#{simulator.name}.zip")
      LOGIN_CONNECTION.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; chmod -R ug+rwx #{simulator.fullname}; mv #{simulator.fullname}/#{Dir.entries(simulator.fullname)[0]} #{simulator.fullname}/#{simulator.name}")
    end
  end
end