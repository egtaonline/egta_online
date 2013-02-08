class SimulatorPrepService
  def initialize(login_connection)
    @login_connection = login_connection
  end

  def cleanup_simulator(simulator, location=Yetting.deploy_path)
    @login_connection.exec!("rm -rf #{location}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
  end

  def prepare_simulator(simulator, location=Yetting.deploy_path)
    @login_connection.exec! "cd #{location} && unzip -uqq #{simulator.name}.zip -d #{simulator.fullname} && chmod -R ug+rwx #{simulator.fullname}"
  end
end