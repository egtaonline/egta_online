class FolderCreator
  @queue = :nyx_actions

  def self.perform(simulation_id)
    @sp ||= ServerProxy.instance
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      puts "creating folder hierarchy for #{simulation.number}"
      simulator = simulation.scheduler.simulator
      Dir.mkdir("tmp/#{simulation.number}")
      Dir.mkdir("tmp/#{simulation.number}/features")
      FileUtils.mv("tmp/temp.yaml", "tmp/#{simulation.number}/simulation_spec.yaml")
      @sp.sftp.upload!("tmp/#{simulation.number}", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}", owner: @sp.staging_session.user, gid: WELLMAN)
      @sp.staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
      puts "hierarchy completed for #{simulation.number}"
      FileUtils.rm_rf("tmp/400")
    end
  end
end