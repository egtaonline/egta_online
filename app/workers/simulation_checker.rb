class SimulationChecker
  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    puts "checking simulations"
    if Simulation.active.length > 0
      simulation_ids = Simulation.active.collect{|s| s.id}
      output = Net::SSH.start(Yetting.host, Account.all.sample.username).exec!("qstat -a | grep mas-")
      state_info = parse_nyx_output(output)
      Account.all.each do |account|
        if Simulation.where(:_id.in => simulation_ids, :account_id => account.id).count != 0
          location = ":/home/wellmangroup/many-agent-simulations/simulations/#{account.username}/"
          numbers = Simulation.where(:_id.in => simulation_ids, :account_id => account.id).collect{|s| location+"#{s.number}"}
          numbers = numbers.join(" ")
          system("sudo rsync -re ssh --chmod=ugo+rwx #{account.username}@nyx-login.engin.umich.edu#{numbers} #{Rails.root}/db/#{account.username}")
          Simulation.where(:_id.in => simulation_ids, :account_id => account.id).each {|s| update_simulation_status(s, state_info[s.job_id])}
        end
      end
    end
  end

  def self.update_simulation_status(simulation, status, folder_name="#{Rails.root}/db/#{simulation.account_username}/#{simulation.number}")
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      if File.exists?(folder_name+"/out")
        check_for_errors(simulation, folder_name)
      else
        simulation.error_message = "Files were not found on nyx."
        simulation.failure!
      end
    end
  end

  def self.parse_nyx_output(output)
    parsed_output = {}
    output.split("\n").each{|line| parsed_output[line.split(".").first] = line.split(/\s+/)[9]} if output != nil
    parsed_output
  end

  def self.check_for_errors(simulation, folder_name="#{Rails.root}/db/#{simulation.account_username}/#{simulation.number}")
    error_message = errors_from_folder(folder_name)
    if error_message == ""
      Resque.enqueue(DataParser, simulation.number)
    else
      simulation.error_message = error_message
      simulation.failure!
    end
  end
  
  def self.errors_from_folder(folder_name)
    if File.open(folder_name+"/out").read == ""
      File.exist?(folder_name+"/payoff_data") ? "" : "Missing payoff data file."
    else
      File.open(folder_name+"/out").read(Yetting.error_store)
    end
  end
end
