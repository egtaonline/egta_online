require 'yaml'
RAILS_ROOT = File.expand_path("../..", __FILE__)

God.watch do |w|
  w.group = "beanstalk"
  w.name = "egta-stalk-worker"
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "/usr/bin/stalk #{RAILS_ROOT}/config/jobs.rb"
  w.log = "#{RAILS_ROOT}/log/stalker.log"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 50.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 1.hours
    end
  end
end

God.watch do |w|
  w.group = "beanstalk"
  w.name = "egta-stalk-queue"
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "/usr/bin/beanstalkd -d"
  w.log = "#{RAILS_ROOT}/log/stalker.log"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 1.hours
    end
  end
end

God.watch do |w|
  w.group = "periodic-jobs"
  w.name = "periodic-daemons"
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "#{RAILS_ROOT}/lib/daemons/periodic_daemon_ctl start"
  w.restart = "#{RAILS_ROOT}/lib/daemons/periodic_daemon_ctl restart"
  w.stop = "#{RAILS_ROOT}/lib/daemons/periodic_daemon_ctl stop"
  w.log = "#{RAILS_ROOT}/log/periodic_daemon.log"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 500.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 1.hours
    end
  end
end

config_path = "/etc/thin"

Dir[config_path + "/*.yml"].each do |file|
  config = YAML.load_file(file)
  num_servers = config["servers"] ||= 1

  for i in 0...num_servers
    God.watch do |w|
      w.group = "thin-" + File.basename(file, ".yml")
      w.name = w.group + "-#{i}"

      w.interval = 30.seconds

      w.uid = config["user"]
      w.gid = config["group"]

      w.start = "thin start -C #{file} -o #{i}"
      w.start_grace = 10.seconds

      w.stop = "thin stop -C #{file} -o #{i}"
      w.stop_grace = 10.seconds

      w.restart = "thin restart -C #{file} -o #{i}"

      pid_path = config["chdir"] + "/" + config["pid"]
      ext = File.extname(pid_path)

      w.pid_file = pid_path.gsub(/#{ext}$/, ".#{i}#{ext}")

      w.behavior(:clean_pid_file)

      w.start_if do |start|
        start.condition(:process_running) do |c|
          c.interval = 5.seconds
          c.running = false
        end
      end

      w.restart_if do |restart|
        restart.condition(:memory_usage) do |c|
          c.above = 150.megabytes
          c.times = [3,5] # 3 out of 5 intervals
        end

        restart.condition(:cpu_usage) do |c|
          c.above = 50.percent
          c.times = 5
        end
      end

      w.lifecycle do |on|
        on.condition(:flapping) do |c|
          c.to_state = [:start, :restart]
          c.times = 5
          c.within = 5.minutes
          c.transition = :unmonitored
          c.retry_in = 10.minutes
          c.retry_times = 5
          c.retry_within = 2.hours
        end
      end
    end
  end
end
