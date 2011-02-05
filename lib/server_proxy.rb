class ServerProxy
  ROOT_DIR = File.dirname(File.expand_path(__FILE__))

  QSTAT_CMD = "/usr/local/torque/bin/qstat"
  def submit_simulations(simulations)
    account = simulations[0].account
    simulator = Simulator.find(Game.find(simulations[0].profile.game_id).simulator_id)
    root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
    Net::SSH.start(account.host, account.username) do |ssh|
      simulations.each do |simulation|
        simulation.logger.info ssh.exec!("cd #{root_path}/../; cp #{DEPLOY_PATH}/setup_hierarchy.rb .; ruby setup_hierarchy.rb #{simulation.id}")
        File.open( "#{ROOT_DIR}/temp.yaml", 'w' ) do |out|
          YAML.dump(NPlayerProfile.find(simulation.profile_id).strategies.collect {|x| x.name}, out )
          p = Hash.new
          Game.find(NPlayerProfile.find(simulation.profile_id).game_id).parameters.each do |x,y|
            if is_a_number?(y)
              p[x] = y.to_f
            else
              p[x] = y
            end
          end
          YAML.dump(p, out)
        end
        Net::SCP::upload!(account.host, account.username, "#{ROOT_DIR}/temp.yaml", "#{root_path}/../simulations/#{simulation.id}/simulation_spec.yaml")
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

#  def check_simulation(simulation)

#    account = simulation.account

#    Net::SSH.start(account.host, account.username) do |ssh|
#      puts simulation.job
#      if simulation.job
#        output = ssh.exec!("#{QSTAT_CMD} -f -1 #{simulation.job}")
#        if output =~ /Unknown Job Id/
#          simulation.fail!
#        elsif output =~ /Job Id:/
#          # Simulation still good
#        else
#          simulation.fail!
#        end

#      end

#    end

#  end




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
        simulations.each do |simulation|
          account = Account.find(simulation.account_id)
          simulator = Simulator.find(Game.find(simulations[0].profile.game_id).simulator_id)
          root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
          if job_id.include?(simulation.job)
            state = state_info[job_id.index(simulation.job)][9]
            if state == "C"
              output = ssh.exec!("if test -e #{root_path}/../simulations/#{simulation.id}/out-#{simulation.id}; then printf \"exists\"; fi")
              if output == "exists"
                Net::SCP.download!(account.host, account.username, "#{root_path}/../simulations/#{simulation.id}", "#{ROOT_DIR}/../db/", :recursive => true)
                if FileUtils.compare_file "#{ROOT_DIR}/../db/#{simulation.id}/out-#{simulation.id}", "#{ROOT_DIR}/empty"
                  gather_samples simulation
                  simulation.finish!
                else
                  simulation.err_message = File.open("#{ROOT_DIR}/../db/#{simulation.id}/out-#{simulation.id}").readline
                  simulation.fail!
                end
              end
            elsif state == "R" && simulation.state != "running"
              simulation.start!
            end
          elsif state != "Q"
            output = ssh.exec!("if test -e #{root_path}/../simulations/#{simulation.id}/out-#{simulation.id}; then printf \"exists\"; fi")
            if output == "exists"
              Net::SCP.download!(account.host, account.username, "#{root_path}/../simulations/#{simulation.id}", "#{ROOT_DIR}/../db/", :recursive => true)
              if FileUtils.compare_file "#{ROOT_DIR}/../db/#{simulation.id}/out-#{simulation.id}", "#{ROOT_DIR}/empty"
                gather_samples simulation
                simulation.finish!
              else
                simulation.err_message = File.open("#{ROOT_DIR}/../db/#{simulation.id}/out-#{simulation.id}").readline
                simulation.fail!
              end
            else
              simulation.fail!
            end
          end

        end
      end
    end


  end

  def gather_samples(simulation)
    count = 0
    @sample
    File.open( "#{ROOT_DIR}/../db/#{simulation.id}/payoff_data", 'r') do |out|
      YAML.load_documents(out) do |yf|
        params = Hash[:size => NPlayerProfile.find(simulation.profile_id).size, :profile_id => simulation.profile_id, :content_type => "text/yaml", :filename => "#{ROOT_DIR}/../db/#{simulation.id}/payoff_data", :file_index => count, :simulation_id => simulation.id]
        @sample = simulation.samples.build(params)
        if !@sample.save
          puts "saving failed"
        end
        count += 1
        players = NPlayerProfile.find(simulation.profile_id).players
        players.each do |player|
          n_player_payoff = NPlayerPayoff.new
          n_player_payoff.sample_id = @sample.id
          n_player_payoff.player_id = player.id
          n_player_payoff.payoff = yf[Strategy.find(player.strategy_id).name]
          n_player_payoff.adjusted = false
          n_player_payoff.n_player_profile_id = simulation.profile_id
          n_player_payoff.save!
        end
      end
    end

    Dir.foreach("#{ROOT_DIR}/../db/#{simulation.id}/features") do |x|
      if !File.directory?("#{ROOT_DIR}/../db/#{simulation.id}/features/"+x)
        File.open("#{ROOT_DIR}/../db/#{simulation.id}/features/"+x) do |out|
          @feature = Feature.find_by_game_id_and_name(NPlayerProfile.find(simulation.profile_id).game_id, x)
          if @feature == nil
            @feature = Feature.new(Hash[:name => x, :game_id => NPlayerProfile.find(simulation.profile_id).game_id])
            if !@feature.save
              puts "saving feature fail"
            end
          end
          count = 0
          YAML.load_documents(out) do |yf|
            feature_sample = FeatureSample.new(Hash[:sample_id => @sample.id-29+count, :feature_id => @feature.id, :value => yf])
            count +=1
            if !feature_sample.save
              puts "saving failed"
            end
          end
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
        jpr = PbsProxy.find(simulation.pbs_proxy_id).jobs_per_request
        if simulations.size >= jpr
         # puts "pending simulation"

          active_simulations = Simulation.active.where(:account_id=>account.id).count
          simulation.logger.info active_simulations

          available_slots = account.max_concurrent_simulations - active_simulations

          submit_simulations(simulations.first(jpr)) if available_slots >= jpr
        end
      end
    end

  end

  private

    def nyx_processing(simulations)
      simulator = Simulator.find(Game.find(simulations[0].profile.game_id).simulator_id)
      root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
      account = simulations[0].account
      submission = PBS::MASSubmission.new(PbsProxy.find(simulations[0].pbs_proxy_id), simulations[0].size, simulations[0].id, "#{root_path}/script/wrapper")
      if simulations[0].flux?
        submission.qos = "wellman_flux"
      end
      simulations.each do |simulation|
        strategies = simulation.profile['profile_hash'].split(',').collect!{|x| x.to_i}.collect do |index|
           Strategy.find(index)
        end if simulation.profile
      end
#        submission.players = strategies.collect {|s| s['id'] } if strategies
      create_wrapper(simulations)
      @job = ""
      Net::SCP::upload!(account.host, account.username, "#{ROOT_DIR}/wrapper", "#{root_path}/script/")
      Net::SSH.start(account.host, account.username) do |ssh|
  f = ssh.exec!("cd #{root_path}/script; chmod g+wrx wrapper")
        f = ssh.exec!("#{submission.command}") if submission
        job_return = f

        job_return.strip! if job_return
        @job = job_return[/^(\d+)/] if job_return && job_return =~ /^(\d+)/
      end
      if submission
        if @job != "" && @job != nil
          simulations.each do |simulation|
            simulation.send('queue!')
            simulation.job = @job+"[]"
            simulation.save
          end
        else
          simulations.each do |simulation|
            simulation.send('fail!')
          end
        end
      end
    end

    def create_wrapper(simulations)
      simulator = Simulator.find(Game.find(simulations[0].profile.game_id).simulator_id)
      root_path = "#{DEPLOY_PATH}/#{simulator.name}-#{simulator.version}/#{simulator.name}"
      FileUtils.cp(ROOT_DIR + "/wrapper-template", File.dirname(__FILE__) + "/wrapper")
      File.open(ROOT_DIR + "/wrapper", "a") do |file|
        if simulations[0].flux?
          file.syswrite("\n\#PBS -A wellman_flux")
          file.syswrite("\n\#PBS -q flux")
        else
          file.syswrite("\n\#PBS -q route")
        end
        file.syswrite("\n\#PBS -N mas-#{Game.find(NPlayerProfile.find(simulations[0].profile_id).game_id).simulator.name.downcase.gsub(' ', '_')}\n")
        str = "\#PBS -t #{simulations[0].id}"
        for i in 1...simulations.size
          str += ",#{simulations[i].id}"
        end
        str += "\n"
        file.syswrite(str)
        file.syswrite("\#PBS -o #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
        file.syswrite("\#PBS -e #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
        file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/${PBS_ARRAYID} .\n")
        file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/${PBS_ARRAYID} #{simulations[0].size}\n")
        file.syswrite("cp -r ${PBS_ARRAYID} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}; chgrp -R wellman #{root_path}/../simulations/${PBS_ARRAYID}; chmod -R ug+wrx #{root_path}/../simulations/${PBS_ARRAYID}")
      end
    end

    def is_a_number?(s)
      s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
end
