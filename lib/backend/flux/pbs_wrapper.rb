class PbsWrapper
  def initialize(simulations_path, flux_simulations_path, simulators_path)
    @simulations_path, @flux_simulations_path, @simulators_path = simulations_path, flux_simulations_path, simulators_path
  end
  
  def create_wrapper(simulation)
    scheduler = simulation.scheduler
    allocation = simulation['flux'] ? 'wellman_flux' : 'cac'
    queue = simulation['flux'] ? 'flux' : 'cac'
    simulator = simulation.scheduler.simulator
    root_path = "#{@simulators_path}/#{simulator.fullname}/#{simulator.name}"
    extra_args = simulation.scheduler_nodes > 1 ? " ${PBS_NODEFILE}" : ""
    sim_path = @flux_simulations_path
    walltime = simulation.size*scheduler.time_per_sample
    pbs_wall_time = [ walltime/3600, (walltime/60) % 60, walltime % 60 ].map{ |time| "%02d" % time }.join(":")


    document = <<HEREDOC
#!/bin/bash
#PBS -S /bin/sh
#PBS -A #{allocation}
#PBS -q #{queue}
#PBS -l nodes=#{simulation.scheduler_nodes},pmem=#{scheduler.process_memory}mb,walltime=#{pbs_wall_time},qos=#{queue}
#PBS -N egta-#{simulator.name.downcase.gsub(' ', '_')}
#PBS -W umask=0007
#PBS -W group_list=wellman
#PBS -o #{sim_path}/#{simulation.id}/out
#PBS -e #{sim_path}/#{simulation.id}/error
#PBS -M #{simulator.email}
umask 0007
mkdir /tmp/${PBS_JOBID}
cp -r #{root_path}/* /tmp/${PBS_JOBID}
cp -r #{sim_path}/#{simulation.id} /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch #{simulation.id} #{simulation.size}#{extra_args}
cp -r /tmp/${PBS_JOBID}/#{simulation.id} #{sim_path}
rm -rf /tmp/${PBS_JOBID}
HEREDOC

    File.open("#{@simulations_path}/#{simulation.id}/wrapper", 'w'){ |f| f.write(document) }
  end
end