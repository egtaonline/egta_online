class PbsWrapper
  def self.create_wrapper(simulation, src_dir)
    scheduler = simulation.scheduler
    allocation = simulation.flux ? 'wellman_flux' : 'cac'
    queue = simulation.flux ? 'flux' : 'cac'
    simulator = simulation.scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    extra_args = simulation.scheduler_nodes > 1 ? " ${PBS_NODEFILE}" : ""
    sim_path = "#{Yetting.deploy_path}/simulations"
    walltime = simulation.size*scheduler.time_per_sample
    pbs_wall_time = [ walltime/3600, (walltime/60) % 60, walltime % 60 ].map{ |time| "%02d" % time }.join(":")


    document = <<HEREDOC
#!/bin/bash
#PBS -S /bin/sh
#PBS -A #{allocation}
#PBS -q #{queue}
#PBS -l nodes=#{simulation.scheduler_nodes},pmem=#{scheduler.process_memory}mb,walltime=#{pbs_wall_time},qos=#{queue}
#PBS -N egta-#{simulator.name.downcase.gsub(' ', '_')}
#PBS -o #{sim_path}/#{simulation.id}/out
#PBS -e #{sim_path}/#{simulation.id}/error
#PBS -M #{simulator.email}

mkdir /tmp/${PBS_JOBID}
cp -r #{root_path}/* /tmp/${PBS_JOBID}
cp -r #{sim_path}/#{simulation.id} /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch #{simulation.id} #{simulation.size}#{extra_args}
cp -r /tmp/${PBS_JOBID}/#{simulation.id} #{sim_path}
chmod -R ug+rw #{sim_path}/#{simulation.id}
rm -rf /tmp/${PBS_JOBID}
HEREDOC

    File.open("#{src_dir}/#{simulation.id}/wrapper", 'w'){ |f| f.write(document) }
  end
end