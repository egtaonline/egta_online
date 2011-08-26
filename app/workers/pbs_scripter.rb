class PBSScripter
  @queue = :nyx_actions

  def self.perform(simulation_id)
    @sp ||= ServerProxy.instance
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      simulator = simulation.scheduler.simulator
      root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
      puts "creating submission"
      submission = Submission.new(simulation.scheduler, simulation.size, simulation.number, "#{root_path}/script/wrapper")
      if (Simulation.active.flux.count+1) < FLUX_LIMIT
        simulation.update_attribute(:flux, true)
        submission.qos = "wellman_flux"
      end
      puts "creating wrapper"
      create_wrapper(simulation)
      puts "scheduling simulation"
      @sp.sftp.upload!("#{Rails.root}/tmp/wrapper", "#{root_path}/script/wrapper", owner: @sp.staging_session.options[:user], gid: WELLMAN)
      @sp.staging_session.exec!("chmod -R ug+rwx #{root_path}")
      @job = get_job(simulation.account, simulator, submission)
      if submission
        if submission && @job != "" && @job != nil
          simulation.send('queue!')
          simulation.job_id = @job
          simulation.save
        else
          puts "submission failed"
          simulation.send('failure!')
        end
      end
    end
  end

  def self.create_wrapper(simulation)
    simulator = simulation.scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp("#{Rails.root}/lib/wrapper-template", "#{Rails.root}/tmp/wrapper")
    File.open("#{Rails.root}/tmp/wrapper", "a") do |file|
      if simulation.flux == true
        file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
      else
        file.syswrite("\n\#PBS -A cac\n\#PBS -q cac")
      end
      file.syswrite("\n\#PBS -N mas-#{simulator.name.downcase.gsub(' ', '_')}\n")
      file.syswrite("\#PBS -o #{root_path}/../simulations/#{simulation.number}/out\n")
      file.syswrite("\#PBS -e #{root_path}/../simulations/#{simulation.number}/out\n")
      file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/#{simulation.number} .\n")
      file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/#{simulation.number} #{simulation.size}\n")
      file.syswrite("chmod -R ug+rwx /tmp/${PBS_JOBID}/#{simulation.number}\n")
      file.syswrite("cp -r /tmp/${PBS_JOBID}/#{simulation.number} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}")
    end
  end

  def self.get_job(account, simulator, submission)
    job_return = ""
    if submission != nil
      channel = @sp.sessions.with(account.username.to_sym).exec("cd #{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}/script; #{submission.command}") do |ch, stream, data|
        job_return = data
        puts "[#{ch[:host]} : #{stream}] #{data}"
        job_return.strip! if job_return != nil
        job_return = job_return.split(".").first
      end
      channel.wait

      if channel[:exit_status] != 0 and channel[:exit_status] != "" and channel[:exit_status] != nil
        puts channel[:exit_status]
      end
    end
    job_return
  end
end