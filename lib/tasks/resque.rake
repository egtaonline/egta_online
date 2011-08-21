require "resque/tasks"

task "resque:setup" => :environment

task "resque:stop_workers" => :environment do
  pids = Array.new

  Resque.workers.each do |worker|
    pids << worker.to_s.split(/:/).second
  end

  if pids.size > 0
    system("sudo kill -QUIT #{pids.join(' ')}")
  end

end
