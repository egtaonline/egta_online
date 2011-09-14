class SimulationChecker
  include Resque::Plugins::UniqueJob
  @queue = :nyx_actions

  def self.perform
    puts "Checking for simulations"
    if Simulation.active.length > 0
      puts "Simulations found"
      simulations = Simulation.active
      output = Net::SSH.start(Yetting.host, Account.all.sample.username).exec!("qstat -a | grep mas-")
      job_id = []
      state_info = []
      if output != nil && output != ""
        outputs = output.split("\n")
        outputs.each do |job|
          job_id << job.split(".").first
          state_info << job.split(/\s+/)
        end
      end
      puts "Updating status"
      Account.all.each do |account|
        if simulations.where(account_id: account.id).count != 0
          location = ":/home/wellmangroup/many-agent-simulations/simulations/#{account.username/}"
          numbers = simulations.where(account_id: account.id).collect{|s| location+"#{s.number}"}
          numbers.join(" ")
          system("sudo rsync -re ssh --chmod=ugo+rwx #{account.username}@nyx-login.engin.umich.edu#{numbers} /home/deployment/current/db/#{account.username}")
          simulations.where(account_id: account.id).each do |s|
            begin
              simulator = s.scheduler.simulator
              if job_id.include?(s.job_id)
                state = state_info[job_id.index(s.job_id)][9]
                if state == "C"
                  puts "checking existance"
                  if File.exists?("#{Rails.root}/db/#{account.username}/#{s.number}/out")
                    puts "checking for errors"
                    check_for_errors(s)
                  end
                elsif state == "R" && s.state != "running"
                  s.start!
                end
              else
                puts "I am checking existance"
                if File.exists?("#{Rails.root}/db/#{account.username}/#{s.number}/out")
                  puts "checking for errors"
                  check_for_errors(s)
                else
                  puts "did not exist"
                  s.error_message = "Did not exist on nyx"
                  s.failure!
                end
              end
            rescue
              s.error_message = "Unknown failure checking status"
              s.failure!
            end
          end
        end
      end
    end
    puts "Finishing"
  end

  def self.check_for_errors(simulation)
    if File.open("#{Rails.root}/db/#{simulation.account.username}/#{simulation.number}/out").read == ""
      if File.exist?("#{Rails.root}/db/#{simulation.account.username}/#{simulation.number}/payoff_data")
        puts "enqueue data parsing"
        Resque.enqueue(DataParser, simulation.number)
      else
        puts "missing payoff data"
        simulation.error_message = "Payoff data is missing, cause unknown."
        simulation.failure!
      end
    else
      simulation.error_message = File.open("#{Rails.root}/db/#{simulation.account.username}/#{simulation.number}/out").read
      simulation.failure!
    end
  end
end
