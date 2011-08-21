require 'yaml'
RAILS_ROOT = File.expand_path("../..", __FILE__)

queues = ["profile_actions", "nyx_actions"]
queues.each do |q|
  God.watch do |w|
    w.name          = "resque-#{q}"
    w.interval      = 30.seconds
    w.start         = "cd #{RAILS_ROOT} && rake environment RAILS_ENV=production resque:work QUEUE=#{q}"
    w.start_grace   = 10.seconds

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
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