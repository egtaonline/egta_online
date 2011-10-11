class SimulatorInitializer
  @queue = :nyx_actions

  def self.perform(simulator_id)
    simulator = Simulator.find(simulator_id) rescue nil
    if simulator != nil
      puts "setting up simulator"
      account = Account.all.sample
      puts "found account"
      ssh = Net::SSH.start(Yetting.host, account.username)
      puts "connected"
      ssh.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
      puts "cleaning"
      ssh.scp.upload!(simulator.simulator_source.path, Yetting.deploy_path)
      ssh.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
      ssh.exec!("cd #{Yetting.deploy_path}; chmod -R ug+rwx #{simulator.fullname}")
    end
  end
end