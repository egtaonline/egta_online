class FolderCreator
  @queue = :nyx_actions

  def self.perform(simulation_id)
    @sp ||= ServerProxy.instance
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      puts "creating folder hierarchy for #{simulation.number}"
      simulator = simulation.scheduler.simulator
      @sp.staging_session.exec!("rm -rf #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
      Dir.mkdir("tmp/#{simulation.number}")
      Dir.mkdir("tmp/#{simulation.number}/features")
      FileUtils.mv("tmp/temp.yaml", "tmp/#{simulation.number}/simulation_spec.yaml")
      @sp.sftp.upload!("tmp/#{simulation.number}", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}", owner: @sp.staging_session.options[:user], gid: WELLMAN)
      @sp.staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
      puts @sp.staging_session.exec!("ls -l #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
      puts "hierarchy completed for #{simulation.number}"
      FileUtils.rm_rf("tmp/#{simulation.number}")
    end
  end
end