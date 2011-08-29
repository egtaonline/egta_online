class SimulationQueuer
  @queue = :nyx_actions

  def self.perform
    simulations = Simulation.pending.all
    simulations.each do |s|
      begin
        puts "preparing to queue #{simulation.number}"
        create_folder(s)
        create_yaml(s)
        NyxWrapper.create_wrapper(s)
      rescue
        s.update_attributes(state: "failed", error_message: "failed to create files for nyx")
      end
    end
    schedule(simulations)
    cleanup(simulations)
  end
  
  def self.create_folder(simulation)
    puts "creating folder hierarchy for #{simulation.number}"
    simulator = simulation.scheduler.simulator
    Dir.mkdir("tmp/#{simulation.number}")
    Dir.mkdir("tmp/#{simulation.number}/features")
    puts "hierarchy completed for #{simulation.number}"
  end
  
  def self.cleanup(simulations)
    simulations.each do |s|
      FileUtils.rm_rf("tmp/#{s.number}")
    end
  end
  
  def self.schedule(simulations)
    Account.all.each do |account|
      Net::SSH.start(Yetting.host, account.username) do |ssh|
        Net::SFTP::Session.new(ssh) do |sftp|
          simulations.where(account_id: account.id).each do |s|
            begin
              simulator = s.scheduler.simulator
              sftp.upload!("tmp/#{s.number}", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}", owner: account.username, gid: WELLMAN)
              ssh.exec!("chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}")
            rescue
              s.update_attributes(state: "failed", error_message: "failed to upload to nyx")
            end
          end
        end
        simulations.where(account_id: account.id).each do |s|
          begin
            simulator = s.scheduler.simulator
            root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
            puts "creating submission"
            submission = Submission.new(s.scheduler, s.size, s.number, "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}/wrapper")
            if (Simulation.active.flux.count+1) < FLUX_LIMIT
              s.update_attribute(:flux, true)
              submission.qos = "wellman_flux"
            end
            puts "scheduling simulation"
            if submission != nil
              ssh.exec("cd #{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}/script; #{submission.command}") do |ch, stream, data|
                job_return = data
                puts "[#{ch[:host]} : #{stream}] #{data}"
                job_return.strip! if job_return != nil
                job_return = job_return.split(".").first
                if job_return != "" and job_return != nil
                  s.send('queue!')
                  s.job_id = job_return
                  s.save!
                else
                  puts "submission failed"
                  s.update_attributes(state: "failed", error_message: "submission failed")
                end
              end
            end
          rescue
            s.update_attributes(state: "failed", error_message: "failed in the submission step")
          end
        end
        ssh.loop
      end
    end
  end
   
  def self.create_yaml(simulation)
    puts "creating simulation_spec.yaml"
    File.open( "#{Rails.root}/tmp/#{simulation.number}/simulation_spec.yaml", 'w' ) do |out|
      YAML.dump(Profile.find(simulation.profile_id).yaml_rep, out)
      YAML.dump(numeralize(simulation.scheduler), out)
    end
  end

  def self.numeralize(scheduler)
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

  def self.is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end