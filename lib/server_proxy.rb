class ServerProxy
  ROOT_DIR = File.dirname(File.expand_path(__FILE__))
  QSTAT_CMD = "/usr/local/torque/bin/qstat"

  def submit_simulations(simulations)
    account = simulations[0].account
    simulator = simulations[0].game.simulator
    root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
    Net::SSH.start(account.host, account.username) do |ssh|
      simulations.each do |simulation|
        ssh.exec!("cd #{root_path}/../; cp -u #{DEPLOY_PATH}/setup_hierarchy.rb .; ruby setup_hierarchy.rb #{simulation.serial_id}")
        File.open( "#{ROOT_DIR}/temp.yaml", 'w' ) do |out|
          YAML.dump(simulation.game.profiles.find(simulation.profile_id).strategy_array, out)
          YAML.dump(numeralize(simulation.game.parameters), out)
        end
        Net::SCP::upload!(account.host, account.username, "#{ROOT_DIR}/temp.yaml", "#{root_path}/../simulations/#{simulation.serial_id}/simulation_spec.yaml")
      end
    end
    if account.host =~ /nyx/
      nyx_processing(simulations)
    else
      Net::SSH.start(account.host, account.username) do |ssh|
        simulations[0].logger.info ssh.exec!("cd #{root_path}; script/batch")
      end
    end
  end

  def check_simulation_new
    account = Account.all.shuffle.first
    simulations = Simulation.active
    if simulations.length > 0
      Net::SSH.start(account.host, account.username) do |ssh|
        output = ssh.exec!("#{QSTAT_CMD} -a | grep mas-")
        job_id = []
        state_info = []
        if output != nil && output != ""
          outputs = output.split("\n")
          outputs.each do |job|
            job_id << job.split(".").first
            state_info << job.split(/\s+/)
          end
        end
        simulations.each {|simulation| check_status(ssh, simulation, job_id, state_info) }
      end
    end
  end

  def check_existance(root_path, simulation)
    output = ssh.exec!("if test -e #{root_path}/../simulations/#{simulation.serial_id}/out-#{simulation.serial_id}; then printf \"exists\"; fi")
    output == "exists"
  end

  def check_for_errors(simulation)
    if FileUtils.compare_file "#{ROOT_DIR}/../db/#{simulation.serial_id}/out-#{simulation.serial_id}", "#{ROOT_DIR}/empty"
      gather_samples simulation
      simulation.finish!
    else
      simulation.error_message = File.open("#{ROOT_DIR}/../db/#{simulation.serial_id}/out-#{simulation.serial_id}").readline
      simulation.fail!
    end
  end

  def check_status(ssh, simulation, job_id, state_info)
    simulator = simulation.game.simulator
    root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
    if job_id.include?(simulation.job_id)
      state = state_info[job_id.index(simulation.job_id)][9]
      if state == "C"
        if check_existance(root_path, simulation)
          Net::SCP.download!(account.host, account.username, "#{root_path}/../simulations/#{simulation.serial_id}", "#{ROOT_DIR}/../db/", :recursive => true)
          check_for_errors(simulation)
        end
      elsif state == "R" && simulation.state != "running"
        simulation.start!
      end
    elsif state != "Q"
      if check_existance(root_path, simulation)
        Net::SCP.download!(account.host, account.username, "#{root_path}/../simulations/#{simulation.serial_id}", "#{ROOT_DIR}/../db/", :recursive => true)
        check_for_errors(simulation)
      else
        simulation.fail!
      end
    end
  end

  def gather_samples(simulation)
    count = 0
    @sample
    File.open( "#{ROOT_DIR}/../db/#{simulation.serial_id}/payoff_data", 'r') do |out|
      YAML.load_documents(out) do |yf|
        @sample = simulation.samples.build(:profile_id => simulation.profile_id, :filename => "#{ROOT_DIR}/../db/#{simulation.serial_id}/payoff_data", :file_index => count)
        count += 1
        players = simulation.game.profiles.find(simulation.profile_id).players
        players.each{|player| player.payoffs.create(:sample_id => @sample.id, :payoff => yf[player.strategy])}
      end
    end
    Dir.foreach("#{ROOT_DIR}/../db/#{simulation.serial_id}/features") do |x|
      File.open("#{ROOT_DIR}/../db/#{simulation.serial_id}/features/"+x) do |out|
        @feature = simulation.game.features.where(:name => x).first ? simulation.game.features.create(:name => x) : simulation.game.features.where(:name => x).first
        count = 0
        YAML.load_documents(out) do |yf|
          @feature.feature_samples.create(:feature_name => @feature.name, :value => yf, :sample_id => simulation.samples.where(:file_index => count).first.id)
          count += 1
        end
      end
    end
  end

  def check_active_simulations
    #puts "active simulation! " + Simulation.active.length
    #Simulation.active.each do |simulation|
    #
    #   check_simulation simulation
    #
    #end
    if Simulation.active.length > 0
      check_simulation_new
    end
  end

  def queue_pending_simulations
    #puts "pending simulation!"

    Simulation.pending.each do |simulation|
      if simulation.state == 'pending'
        account = simulation.account
        simulations = Simulation.where(:state => 'pending', :account_id => account.id)
        jpr = PbsGenerator.find(simulation.pbs_generator_id).jobs_per_request
        if simulations.size >= jpr
         # puts "pending simulation"

          active_simulations = Simulation.active.where(:account_id=>account.id).count

          available_slots = account.max_concurrent_simulations - active_simulations

          submit_simulations(simulations.limit(jpr)) if available_slots >= jpr
        end
      end
    end

  end

  private
    def get_job(account, root_path, submission)
      job = ""
      Net::SSH.start(account.host, account.username) do |ssh|
        job_return = ssh.exec!("cd #{root_path}/script; chmod g+wrx wrapper; #{submission.command}") if submission
        job_return.strip! if job_return
        job = job_return[/^(\d+)/] if job_return =~ /^(\d+)/
      end
      return job
    end

    def nyx_processing(simulations)
      simulator = simulations[0].game.simulator
      root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
      account = simulations[0].account
      submission = PBS::MASSubmission.new(PbsGenerator.find(simulations[0].pbs_generator_id), simulations[0].size, simulations[0].serial_id, "#{root_path}/script/wrapper")
      submission.qos = "wellman_flux" if simulations[0].flux?
      create_wrapper(simulations)
      Net::SCP::upload!(account.host, account.username, "#{ROOT_DIR}/wrapper", "#{root_path}/script/")
      @job = get_job(account, root_path, submission)
      if submission
        if submission && @job != "" && @job != nil
          simulations.each do |simulation|
            simulation.send('queue!')
            simulation.job_id = @job+"[]"
            simulation.save
          end
        else
          simulations.each{|simulation| simulation.send('fail!')}
        end
      end
    end

    def create_wrapper(simulations)
      simulator = simulations[0].game.simulator
      root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
      FileUtils.cp(ROOT_DIR + "/wrapper-template", File.dirname(__FILE__) + "/wrapper")
      File.open(ROOT_DIR + "/wrapper", "a") do |file|
        if simulations[0].flux?
          file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
        else
          file.syswrite("\n\#PBS -q route")
        end
        file.syswrite("\n\#PBS -N mas-#{simulator.name.downcase.gsub(' ', '_')}\n")
        str = "\#PBS -t #{simulations[0].serial_id}"
        simulations.size.times {|i| str += ",#{simulations[i].serial_id}"}
        str += "\n"
        file.syswrite(str)
        file.syswrite("\#PBS -o #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
        file.syswrite("\#PBS -e #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
        file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/${PBS_ARRAYID} .\n")
        file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/${PBS_ARRAYID} #{simulations[0].size}\n")
        file.syswrite("cp -r ${PBS_ARRAYID} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}; chgrp -R wellman #{root_path}/../simulations/${PBS_ARRAYID}; chmod -R ug+wrx #{root_path}/../simulations/${PBS_ARRAYID}")
      end
    end

    private

    def is_a_number?(s)
      s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end

    def numeralize(params)
      p = Hash.new
      params.each do |x|
        if is_a_number?(game[x])
          p[x] = simulation.game[x].to_f
        else
          p[x] = simulation.game[x]
        end
      end
      p
    end
end
