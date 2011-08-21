require 'yaml'
RAILS_ROOT = File.expand_path("../..", __FILE__)

# God.watch do |w|
#   w.group = "beanstalk"
#   w.name = "egta-stalk-worker"
#   w.interval = 50.seconds
#   w.env = {"RAILS_ENV" => "production"}
#   w.start = "stalk #{RAILS_ROOT}/config/jobs.rb"
#   w.log = "#{RAILS_ROOT}/log/stalker.log"
#
#   w.start_if do |start|
#     start.condition(:process_running) do |c|
#       c.running = false
#     end
#   end
#
#   w.restart_if do |restart|
#     restart.condition(:memory_usage) do |c|
#       c.above = 1000.megabytes
#       c.times = [3, 5] # 3 out of 5 intervals
#     end
#
#     restart.condition(:cpu_usage) do |c|
#       c.above = 75.percent
#       c.times = 5
#     end
#   end
#
#   w.lifecycle do |on|
#     on.condition(:flapping) do |c|
#       c.to_state = [:start, :restart]
#       c.times = 5
#       c.within = 5.minute
#       c.transition = :unmonitored
#       c.retry_in = 10.minutes
#       c.retry_times = 5
#       c.retry_within = 1.hours
#     end
#   end
# end
#
# God.watch do |w|
#   w.group = "beanstalk"
#   w.name = "egta-stalk-queue"
#   w.interval = 30.seconds
#   w.env = {"RAILS_ENV" => "production"}
#   w.start = "beanstalkd"
#   w.log = "#{RAILS_ROOT}/log/stalker.log"
#
#   w.start_if do |start|
#     start.condition(:process_running) do |c|
#       c.running = false
#     end
#   end
#
#   w.restart_if do |restart|
#     restart.condition(:memory_usage) do |c|
#       c.above = 100.megabytes
#       c.times = [3, 5] # 3 out of 5 intervals
#     end
#
#     restart.condition(:cpu_usage) do |c|
#       c.above = 50.percent
#       c.times = 5
#     end
#   end
#
#   w.lifecycle do |on|
#     on.condition(:flapping) do |c|
#       c.to_state = [:start, :restart]
#       c.times = 5
#       c.within = 5.minute
#       c.transition = :unmonitored
#       c.retry_in = 10.minutes
#       c.retry_times = 5
#       c.retry_within = 1.hours
#     end
#   end
# end

# %w{6379}.each do |port|
#   God.watch do |w|
#     w.name          = "redis"
#     w.interval      = 30.seconds
#     w.start         = "/etc/init.d/redis-server start"
#     w.stop          = "/etc/init.d/redis-server stop"
#     w.restart       = "/etc/init.d/redis-server restart"
#     w.start_grace   = 10.seconds
#     w.restart_grace = 10.seconds
#
#     w.start_if do |start|
#       start.condition(:process_running) do |c|
#           c.interval = 5.seconds
#           c.running = false
#       end
#     end
#   end
# end

queues = ["profile_actions", "nyx_actions"]
queue.each do |q|
  God.watch do |w|
    w.name          = "resque-#{q}"
    w.interval      = 30.seconds
    w.start         = "cd #{RAILS_ROOT} && RAILS_ENV=production rake environment resque:work QUEUE=#{q}"
    w.start_grace   = 10.seconds

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 500.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end