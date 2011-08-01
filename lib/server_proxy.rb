class ServerProxy

  attr_accessor :sessions, :staging_session

  def start
    @sessions = Net::SSH::Multi.start
    if Account.all.count > 0
      @staging_session = Net::SSH.start(Yetting.host, Account.first.username, :password => Account.first.password)
    end
    @sessions.group :scheduling do
      Account.all.each {|account| self.add_account(account)}
    end
  end

  def add_account(account)
    if @staging_session == nil
      @staging_session = Net::SSH.start(Yetting.host, account.username, :password => account.password)
    end
    @sessions.use(Yetting.host, :user => account.username, :password => account.password)
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

  def queue_pending_simulations
    while Simulation.pending.count > 0
      puts "step"
      first_sim = Simulation.pending.first
      queue_account = Account.active.sample
      if queue_account != nil
        simulations = Array.new
        first_sim.scheduler.simulations.pending.limit(first_sim.scheduler.jobs_per_request).each do |simulation|
          simulation.update_attributes(:account_id => queue_account.id)
          simulations << simulation
        end
        simulations.each do |simulation|
          puts "creating yaml"
          create_yaml(simulation)
          puts "creating hierarchy"
          setup_hierarchy(simulation)
        end
        puts "nyx processing"
        nyx_processing(simulations)
      end
    end
  end

  def check_simulations
    if Simulation.active.length > 0
      simulations = Simulation.active
      output = @staging_session.exec!("qstat -a | grep mas-")
      job_id = []
      state_info = []
      if output != nil && output != ""
        outputs = output.split("\n")
        outputs.each do |job|
          job_id << job.split(".").first
          state_info << job.split(/\s+/)
        end
      end
      simulations.each {|simulation| check_status(simulation, job_id, state_info) }
    end
  end

  def create_yaml(simulation)
    File.open( "#{Rails.root}/tmp/temp.yaml", 'w' ) do |out|
      YAML.dump(Profile.find(simulation.profile_id).yaml_rep, out)
      YAML.dump(numeralize(simulation.scheduler), out)
    end
  end

  def setup_hierarchy(simulation)
    simulator = simulation.scheduler.simulator
    @staging_session.exec!("mkdir -p #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/features")
    @staging_session.scp.upload!("#{Rails.root}/tmp/temp.yaml", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}/simulation_spec.yaml")
    @staging_session.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{simulation.number}")
  end

  def nyx_processing(simulations)
    simulator = simulations[0].scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    account = simulations[0].account
    submission = PBS::MASSubmission.new(simulations[0].scheduler, simulations[0].size, simulations[0].number, "#{root_path}/script/wrapper")
    submission.qos = "wellman_flux" if simulations[0].flux?
    create_wrapper(simulations)
    @staging_session.scp.upload!("#{Rails.root}/tmp/wrapper", "#{root_path}/script/")
    @staging_session.exec!("chmod -R ug+rwx #{root_path}; chgrp -R wellman #{root_path}")
    @job = get_job(account, simulator, submission)
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

  def create_wrapper(simulations)
    simulator = simulations[0].scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp("#{Rails.root}/lib/wrapper-template", "#{Rails.root}/tmp/wrapper")
    File.open("#{Rails.root}/tmp/wrapper", "a") do |file|
      if simulations[0].flux?
        file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
      else
        file.syswrite("\n\#PBS -q route")
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

  def check_existance(root_path, simulation)
    output = @staging_session.exec!("if test -e #{root_path}/../simulations/#{simulation.number}/out-#{simulation.number}; then printf \"exists\"; fi")
    output == "exists"
  end

  def check_for_errors(simulation)
    if File.open("#{Rails.root}/db/#{simulation.number}/out-#{simulation.number}").read == ""
      if File.exist?("#{Rails.root}/db/#{simulation.number}/payoff_data")
        DataParser.parse(simulation.number)
        simulation.finish!
      else
        simulation.error_message = "Payoff data is missing, cause unknown."
        simulation.failure!
      end
    else
      simulation.error_message = File.open("#{Rails.root}/db/#{simulation.number}/out-#{simulation.number}").read
      simulation.failure!
    end
  end

  def check_status(simulation, job_id, state_info)
    simulator = simulation.scheduler.simulator
    root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
    if job_id.include?(simulation.job_id)
      state = state_info[job_id.index(simulation.job_id)][9]
      puts state_info
      if state == "C"
        if check_existance(root_path, simulation)
          server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
          server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
          check_for_errors(simulation)
        end
      elsif state == "R" && simulation.state != "running"
        simulation.start!
      end
    else
      if check_existance(root_path, simulation)
        server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
        server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
        check_for_errors(simulation)
      else
        simulation.failure!
      end
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

  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def numeralize(scheduler)
    p = Hash.new
    scheduler.parameter_hash.each_pair do |x, y|
      if is_a_number?(y)
        p[x] = y.to_f
      else
        p[x] = y
      end
    end
    p
  end
end
