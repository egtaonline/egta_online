class NyxWrapper
  def self.create_wrapper(simulation)
    simulator = simulation.scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp("#{Rails.root}/lib/wrapper-template", "#{Rails.root}/tmp/#{simulation.account.username}/#{simulation.number}/wrapper")
    File.open("#{Rails.root}/tmp/#{simulation.number}/wrapper", "a") do |file|
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
end