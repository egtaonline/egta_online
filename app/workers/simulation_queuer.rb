class SimulationQueuer
  include Resque::Plugins::UniqueJob
  @queue = :nyx_queuing

  def self.perform
    simulations = Simulation.pending.order_by([[:created_at, :asc]]).limit(30).to_a
    cleanup
    simulations.each do |s|
      begin
        create_folder(s)
        create_yaml(s)
        if (Simulation.active.flux.count+1) <= FLUX_LIMIT || Simulation.active.where(:flux => false).count > Simulation.active.flux.count
          s.update_attribute(:flux, true)
        end
        NyxWrapper.create_wrapper(s)
      rescue
        s.error_message = "failed to create files for nyx"
        s.failure!
      end
    end
    if simulations != nil && simulations != []
      schedule(Simulation.pending.any_in(_id: simulations.collect{|s| s.id}))
      cleanup
    end
  end

  def self.create_folder(simulation)
    FileUtils.mkdir_p("tmp/#{simulation.account_username}/#{simulation.number}/features")
  end

  def self.cleanup
    Account.all.each do |a|
      FileUtils.rm_rf("tmp/#{a.username}")
    end
  end

  def self.schedule(simulations)
    Account.active.each do |account|
      if simulations.where(account_id: account.id).count > 0
        scp = Net::SCP.start(Yetting.host, account.username)
        begin
          scp.upload!("tmp/#{account.username}", "#{Yetting.deploy_path}/simulations", recursive: true) do |ch, name, sent, total|
            puts "#{name}: #{sent}/#{total}"
          end
        rescue
          puts "failed account: #{account.username}"
        end
        puts "submission"
        Net::SSH.start(Yetting.host, account.username) do |ssh|
          puts "started"
          simulations.where(account_id: account.id).each do |s|
            begin
              simulator = s.scheduler.simulator
              root_path = "#{Yetting.deploy_path}/#{simulator.fullname}/#{simulator.name}"
              submission = Submission.new(s.scheduler, s.size, s.number, "#{Yetting.deploy_path}/simulations/#{account.username}/#{s.number}/wrapper", s.scheduler.nodes)
              if s.flux == true
                submission.qos = "wellman_flux"
              end
              if submission != nil
                channel = ssh.exec("#{submission.command}") do |ch, stream, data|
                  if stream == :std_err
                    s.error_message = "submission failed: #{data}"
                    s.failure!
                  else
                    job_return = data
                    puts "[#{ch[:host]} : #{stream}] #{data}"
                    job_return.strip! if job_return != nil
                    job_return = job_return.split(".").first
                    if job_return != "" and job_return != nil and is_a_number?(job_return)
                      s.send('queue!')
                      s.job_id = job_return
                      s.save!
                    else
                      if s.state != 'failed'
                        s.error_message = "submission failed: #{job_return}"
                        s.failure!
                      end
                    end
                  end
                end
                channel.wait
              end
            rescue Exception => e
              if s.state != 'failed'
                s.error_message = "failed in the submission step: #{e.message}"
                s.failure!
              else
                puts e.message
              end
            end
          end
        end
      end
    end
  end

  def self.create_yaml(simulation)
    File.open( "#{Rails.root}/tmp/#{simulation.account_username}/#{simulation.number}/simulation_spec.yaml", 'w' ) do |out|
      YAML.dump(Profile.find(simulation.profile_id).as_map, out)
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