class SimulationQueuer
  @queue = :nyx_actions

  def self.perform
    simulations = Simulation.pending.all
    puts "finding simulations"
    cleanup(simulations)
    simulations.each do |s|
      begin
        puts "preparing to queue #{s.number}"
        create_folder(s)
        puts "folder made"
        create_yaml(s)
        puts "yaml made"
        NyxWrapper.create_wrapper(s)
        puts "wrapper made"
      rescue
        s.error_message = "failed to create files for nyx"
        s.failure!
      end
    end
    if simulations != nil && simulations != []
      schedule(simulations)
      cleanup(simulations)
    end
  end
  
  def self.create_folder(simulation)
    puts "creating folder hierarchy for #{simulation.number}"
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
              puts "uploading"
              sftp.upload!("tmp/#{s.number}", "#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}", owner: account.username, gid: WELLMAN)
            rescue
              s.error_message = "failed to upload to nyx"
              s.failure!
            end
          end
        end
        simulations.where(account_id: account.id).each do |s|
          begin
            simulator = s.scheduler.simulator
            puts ssh.exec!("ls -l #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}; chmod -R ug+rwx #{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{s.number}")
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
                  s.error_message = "submission failed"
                  s.failure!
                end
              end
            end
          rescue
            s.error_message = "failed in the submission step"
            s.failure!
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