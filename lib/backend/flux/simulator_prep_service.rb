class SimulatorPrepService
  def initialize(login_connection)
    @login_connection = login_connection
  end
  
  def cleanup_simulator(simulator)
    @login_connection.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
  end
  
  def prepare_simulator(simulator)
    @login_connection.exec! "cd #{Yetting.deploy_path} && unzip -uqq #{simulator.name}.zip -d #{simulator.fullname} && chmod -R ug+rwx #{simulator.fullname}"
  end
end