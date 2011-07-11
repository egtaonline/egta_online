class ServerProxy

  attr_accessor :sessions, :staging_session

  def start
    @sessions = Net::SSH::Multi.start
    @staging_session = Net::SSH.start(Yetting.host, Account.first.username, :password => Account.first.password)
    @sessions.group :scheduling do
      Account.all.each {|account| @sessions.use(Yetting.host, :user => account.username, :password => account.password)}
    end
  end

  def stop
    @sessions.close
    @staging_session.close
  end

  def setup_simulator(simulator)
    @staging_session.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}*; rm -rf #{Yetting.deploy_path}/#{simulator.name}.zip")
    @staging_session.scp.upload!(simulator.simulator_source.path, Yetting.deploy_path)
    @staging_session.exec!("cd #{Yetting.deploy_path}; unzip -uqq #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
    @staging_session.exec!("cd #{Yetting.deploy_path}; chmod -R ug+rwx #{simulator.fullname}")
  end
end