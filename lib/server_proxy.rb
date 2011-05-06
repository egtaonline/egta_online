class ServerProxy
  def initialize(host = "nyx-login.engin.umich.edu", location = "/home/wellmangroup/many-agent-simulations")
    @host = host
    @location = location
  end

  attr_reader :sessions, :staging_session, :host, :location

  def start
    @sessions = Net::SSH::Multi.start
    @staging_session = Net::SSH.start(@host, Account.first.username, :password => Account.first.password)
    @sessions.group :scheduling do
      Account.all.each {|account| @sessions.use(@host, :user => account.username, :password => account.password)}
    end
  end

  def setup_simulator(simulator)
    @staging_session.exec!("rm -rf #{@location}/#{simulator.name}*")
    puts "removed"
    @staging_session.scp.upload!(simulator.simulator.path, @location)
    puts "uploaded"
    @staging_session.exec!("cd #{@location}; unzip -u #{simulator.name}.zip -d #{simulator.fullname}; mkdir #{simulator.fullname}/simulations")
    puts "unzipped"
    @staging_session.exec!("cd #{@location}; chmod -R ug+rwx #{simulator.fullname}")
  end

  def queue_pending_simulations
    queue_account = Account.first
    while Simulation.pending.count != 0 && queue_account != nil
      first_sim = Simulation.pending.first
      queue_account = Account.all.select{|account| account.max_concurrent_simulations-Simulation.active.where(:account_id => account.id).count >= first_sim.scheduler.jobs_per_request}.sample
      if queue_account != nil
        simulations = Array.new
        Simulation.pending.where(:game_id => first_sim.game_id).limit(first_sim.scheduler.jobs_per_request).each do |simulation|
          simulation.update_attributes(:account_id => queue_account.id)
          simulations << simulation
        end
        simulations.each do |simulation|
          setup_hierarchy(simulation)
          create_yaml(simulation)
        end
        nyx_processing(simulations)
      end
    end
  end

  def check_simulations
    if Simulation.active.length > 0
      simulations = Simulation.active
      if simulations.length > 0
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
  end

  def gather_samples(simulation, sample_location = "#{ROOT_PATH}/db")
    count = 0
    File.open(sample_location+"/#{simulation.serial_id}/payoff_data", 'r') do |out|
      YAML.load_documents(out) do |yf|
        sample = simulation.samples.create!(:filename => "#{sample_location}/#{simulation.serial_id}/payoff_data", :file_index => count)
        count += 1
        players = simulation.game.profiles.find(simulation.profile_id).players
        players.each do |player|
          player.payoffs.create!(:sample_id => sample.id, :payoff => yf[player.strategy].to_f)
          sample.save!
        end
      end
    end
  end

  def gather_features(simulation, sample_location ="#{ROOT_PATH}/db")
    dirs = Dir.entries("#{sample_location}/#{simulation.serial_id}/features") - [".", ".."]
    dirs.each do |x|
      File.open("#{sample_location}/#{simulation.serial_id}/features/"+x) do |out|
        @feature = simulation.game.features.where(:name => x).count == 0 ? simulation.game.features.create(:name => x) : simulation.game.features.where(:name => x).first
        count = 0
        YAML.load_documents(out) do |yf|
          @feature.feature_samples.create(:feature_name => @feature.name, :value => yf, :sample_id => simulation.samples.where(:file_index => count).first.id)
          count += 1
        end
      end
    end
  end

  private

  def create_yaml(simulation)
    File.open( "#{ROOT_PATH}/tmp/temp.yaml", 'w' ) do |out|
      YAML.dump(simulation.game.profiles.find(simulation.profile_id).strategy_array, out)
      YAML.dump(numeralize(simulation), out)
    end
  end

  def setup_hierarchy(simulation)
    @staging_session.exec!("mkdir -p #{@location}/#{simulation.game.simulator.fullname}/simulations/#{simulation.serial_id}/features")
    @staging_session.scp.upload!("#{ROOT_PATH}/tmp/temp.yaml", "#{@location}/#{simulation.game.simulator.fullname}/simulations/#{simulation.serial_id}/simulation_spec.yaml")
  end

  def nyx_processing(simulations)
    simulator = simulations[0].game.simulator
    root_path = "#{@location}/#{simulator.fullname}/#{simulator.name}"
    account = simulations[0].account
    submission = PBS::MASSubmission.new(simulations[0].scheduler, simulations[0].size, simulations[0].serial_id, "#{root_path}/script/wrapper")
    submission.qos = "wellman_flux" if simulations[0].flux?
    create_wrapper(simulations)
    @staging_session.scp.upload!("#{ROOT_PATH}/tmp/wrapper", "#{root_path}/script/")
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
        simulations.each{|simulation| simulation.send('fail!')}
      end
    end
  end

  def create_wrapper(simulations)
    simulator = simulations[0].game.simulator
    root_path = "#{@location}/#{simulator.fullname}/#{simulator.name}"
    FileUtils.cp(ROOT_PATH + "/tmp/wrapper-template", ROOT_PATH + "/tmp/wrapper")
    File.open(ROOT_PATH + "/tmp/wrapper", "a") do |file|
      if simulations[0].flux?
        file.syswrite("\n\#PBS -A wellman_flux\n\#PBS -q flux")
      else
        file.syswrite("\n\#PBS -q route")
      end
      file.syswrite("\n\#PBS -N mas-#{simulator.name.downcase.gsub(' ', '_')}\n")
      str = "\#PBS -t "
      simulations.each_index do |i|
        if i == 0
          str += "#{simulations[0].serial_id}"
        else
          str += ",#{simulations[i].serial_id}"
        end
      end
      str += "\n"
      file.syswrite(str)
      file.syswrite("\#PBS -o #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("\#PBS -e #{root_path}/../simulations/${PBS_ARRAYID}/out\n")
      file.syswrite("mkdir /tmp/${PBS_JOBID}; cd /tmp/${PBS_JOBID}; cp -r #{root_path}/* .; cp -r #{root_path}/../simulations/${PBS_ARRAYID} .\n")
      file.syswrite("/tmp/${PBS_JOBID}/script/batch /tmp/${PBS_JOBID}/${PBS_ARRAYID} #{simulations[0].size}\n")
      file.syswrite("cp -r ${PBS_ARRAYID} #{root_path}/../simulations; /bin/rm -rf /tmp/${PBS_JOBID}; chown -R #{@staging_session.options[:user]} #{root_path}/../simulations/${PBS_ARRAYID}")
    end
  end

  def check_existance(root_path, simulation)
    output = @staging_session.exec!("if test -e #{root_path}/../simulations/#{simulation.serial_id}/out-#{simulation.serial_id}; then printf \"exists\"; fi")
    output == "exists"
  end

  def check_for_errors(simulation)
    if File.open("#{ROOT_PATH}/db/#{simulation.serial_id}/out-#{simulation.serial_id}").read == ""
      gather_samples simulation
      gather_features simulation
      simulation.finish!
    else
      simulation.error_message = File.open("#{ROOT_PATH}/db/#{simulation.serial_id}/out-#{simulation.serial_id}").readline
      simulation.fail!
    end
  end

  def check_status(simulation, job_id, state_info)
    simulator = simulation.game.simulator
    root_path = "#{@location}/#{simulator.fullname}/#{simulator.name}"
    if job_id.include?(simulation.job_id)
      state = state_info[job_id.index(simulation.job_id)][9]
      puts state_info
      if state == "C"
        if check_existance(root_path, simulation)
          @staging_session.scp.download!("#{root_path}/../simulations/#{simulation.serial_id}", "#{ROOT_PATH}/db/", :recursive => true)
          check_for_errors(simulation)
        end
      elsif state == "R" && simulation.state != "running"
        simulation.start!
      end
    elsif state != "Q"
      if check_existance(root_path, simulation)
        @staging_session.scp.download!("#{root_path}/../simulations/#{simulation.serial_id}", "#{ROOT_PATH}/db/", :recursive => true)
        check_for_errors(simulation)
      else
        simulation.fail!
      end
    end
  end

  def get_job(account, simulator, submission)
    job_return = ""
    if submission != nil
      server = @sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == account.username}
      channel = server.session(true).exec("cd #{@location}/#{simulator.fullname}/#{simulator.name}/script; #{submission.command}") do |ch, stream, data|
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

  def numeralize(simulation)
    p = Hash.new
    simulation.game.parameters.each do |x|
      if is_a_number?(simulation.game[x])
        p[x] = simulation.game[x].to_f
      else
        p[x] = simulation.game[x]
      end
    end
    p
  end
end
