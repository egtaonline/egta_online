class PBSScripter
  @queue = :nyx_actions

  def self.perform(simulation_ids)
    first_simulation = Simulation.where(id: simulation_ids[0]).first
    if first_simulation != nil
      simulations = simulation_ids.collect{|sim| Simulation.where(id: sim)}.compact
      simulator = first_simulation.scheduler.simulator
      root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
      submission = Submission.new(first_simulation.scheduler, first_simulation.size, first_simulation.number, "#{root_path}/script/wrapper", simulations.size)
      if (Simulation.active.flux.count+simulations.size) < FLUX_LIMIT
        simulations.each {|sim| sim.update_attribute(:flux, true)}
        submission.qos = "wellman_flux"
      end
      create_wrapper(simulations)
      Resque::NYX_PROXY.staging_session.scp.upload!("#{Rails.root}/tmp/wrapper", "#{root_path}/script/")
      Resque::NYX_PROXY.staging_session.exec!("chmod -R ug+rwx #{root_path}; chgrp -R wellman #{root_path}")
      @job = get_job(Account.active.sample, simulator, submission)
      if submission
        if submission && @job != "" && @job != nil
          simulations.each do |simulation|
            simulation.send('queue!')
            simulation.job_id = @job
            simulation.save
          end
        else
          simulations.each{|simulation| simulation.send('failure!')}
        end
      end
    end
  end

  def create_wrapper(simulations)
    simulator = simulations[0].scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp("#{Rails.root}/lib/wrapper-template", "#{Rails.root}/tmp/wrapper")
    File.open("#{Rails.root}/tmp/wrapper", "a") do |file|
      if simulations[0].flux?
        file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
      else
        file.syswrite("\n\#PBS -A cac\n\#PBS -q cac")
      end
      file.syswrite("\n\#PBS -N mas-#{simulator.name.downcase.gsub(' ', '_')}\n")
      str = "\#PBS -t "
      simulations.each_index do |i|
        if i == 0
          str += "#{simulations[0].number}"
        else
          str += ",#{simulations[i].number}"
        end
      end
      str += "\n"
      file.syswrite(str)
      file.syswrite("\#PBS -o #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("\#PBS -e #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/${PBS_ARRAYID} .\n")
      file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/${PBS_ARRAYID} #{simulations[0].size}\n")
      file.syswrite("cp -r ${PBS_ARRAYID} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}")
    end
  end

  def get_job(account, simulator, submission)
    job_return = ""
    if submission != nil
      server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == account.username}
      channel = server.session(true).exec("cd #{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}/script; #{submission.command}") do |ch, stream, data|
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