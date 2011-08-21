require "resque/tasks"

task "resque:setup" => :environment

namespace :queue do
  task :stop_workers => :environment do
    pids = Array.new

    Resque.workers.each do |worker|
      pids << worker.to_s.split(/:/).second
    end

    if pids.size > 0
      system("kill -QUIT #{pids.join(' ')}")
    end

  end
end