class SimulationChecker
#  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    if Simulation.active.length > 0
      simulations = Simulation.active.to_a
      output = LOGIN_CONNECTION.exec!("qstat -a | grep mas-")
      state_info = parse_qstat_output(output)
      location = "#{Yetting.deploy_path}/simulations/"
      simulations.each do |simulation|
        begin
          TRANSFER_CONNECTION.download!("#{location}#{simulation.number}", "#{Rails.root}/db/", recursive: true)
          update_simulation_status(simulation, state_info[simulation.job_id])
        rescue
          puts "scp failed for #{simulation.number}"
        end
      end
    end
  end

  def self.update_simulation_status(simulation, status, folder_name="#{Rails.root}/db/#{simulation.number}")
    case status
    when "R"
      simulation.start!
    when "C", "", nil
      if File.exists?(folder_name+"/out")
        check_for_errors(simulation, folder_name)
      else
        simulation.error_message = "Files were not found on remote server."
        simulation.failure!
      end
    end
  end

  def self.parse_qstat_output(output)
    parsed_output = {}
    output.split("\n").each{|line| parsed_output[line.split(".").first] = line.split(/\s+/)[9]} if output != nil
    parsed_output
  end

  def self.check_for_errors(simulation, folder_name="#{Rails.root}/db/#{simulation.number}")
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
