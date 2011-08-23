class SimulationStatusChecker
  @queue = :nyx_actions

  def self.perform(simulation_id, job_id, state_info)
    @sp ||= ServerProxy.instance
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
            server = @sp.sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
            server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
            check_for_errors(simulation)
          end
        elsif state == "R" && simulation.state != "running"
          simulation.start!
        end
      else
        puts "I am checking existance"
        if check_existance(root_path, simulation)
          puts "existed"
          server = @sp.sessions.servers_for(:scheduling).flatten.detect{|serv| serv.user == simulation.account.username}
          puts "downloading"
          server.session(true).scp.download!("#{root_path}/../simulations/#{simulation.number}", "#{Rails.root}/db/", :recursive => true)
          puts "checking for errors"
          check_for_errors(simulation)
        else
          puts "did not exist"
          simulation.failure!
        end
      end
    end
  end

  def self.check_existance(root_path, simulation)
    output = @sp.staging_session.exec!("if test -e #{root_path}/../simulations/#{simulation.number}/out; then printf \"exists\"; fi")
    puts output
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