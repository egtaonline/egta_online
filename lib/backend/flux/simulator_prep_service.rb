class SimulatorPrepService
  def initialize(login_connection, simulators_path)
    @login_connection, @simulators_path = login_connection, simulators_path
  end

  def cleanup_simulator(simulator)
    @login_connection.exec!("rm -rf #{@simulators_path}/#{simulator.fullname}*; rm -rf #{@simulators_path}/#{simulator.name}.zip")
  end

  def prepare_simulator(simulator)
    @login_connection.exec! "cd #{@simulators_path} && unzip -uqq #{simulator.name}.zip -d #{simulator.fullname} && chmod -R ug+rwx #{simulator.fullname}"
  end
end