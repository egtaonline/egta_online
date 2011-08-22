class SimulationStatusChecker
  @queue = :nyx_actions

  def self.perform(simulation_id, job_id, state_info)
    if NYX_PROXY == nil
      puts "FAIL"
    end
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      puts "checking against jobs"
      simulator = simulation.scheduler.simulator
      root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
      if job_id.include?(simulation.job_id)
        state = state_info[job_id.index(simulation.job_id)][9]
        puts state_info
        if state == "C"
          puts "checking existance"
          if check_existance(root_path, simulation)
            server = NYX_PROXY.sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
            server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
            check_for_errors(simulation)
          end
        elsif state == "R" && simulation.state != "running"
          simulation.start!
        end
      else
        puts "checking existance"
        if check_existance(root_path, simulation)
          server = NYX_PROXY.sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
          puts "downloading"
          server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
          puts "checking for errors"
          check_for_errors(simulation)
        else
          simulation.failure!
        end
      end
    end
  end

  def self.check_existance(root_path, simulation)
    puts NYX_PROXY.staging_session.inspect
    puts Account.count
    output = NYX_PROXY.staging_session.exec!("if test -e #{root_path}/../simulations/#{simulation.number}/out-#{simulation.number}; then printf \"exists\"; fi")
    output == "exists"
  end

  def self.check_for_errors(simulation)
    if File.open("#{Rails.root}/db/#{simulation.number}/out-#{simulation.number}").read == ""
      if File.exist?("#{Rails.root}/db/#{simulation.number}/payoff_data")
        puts "enqueue data parsing"
        Resque.enqueue(DataParser, simulation.number)
      else
        puts "missing payoff data"
        simulation.error_message = "Payoff data is missing, cause unknown."
        simulation.failure!
      end
    else
      simulation.error_message = File.open("#{Rails.root}/db/#{simulation.number}/out-#{simulation.number}").read
      simulation.failure!
    end
  end
end