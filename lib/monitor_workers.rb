WORKER_TIMEOUT = 60 * 30 # 30 minutes

loop do
  begin
    `ps -e -o pid,command | grep [r]esque`.split("\n").each do |line|
      parts   = line.split(' ')
      next if parts[-2] != "at"
      started = parts[-1].to_i
      elapsed = Time.now - Time.at(started)
      if elapsed >= WORKER_TIMEOUT
        ::Process.kill('USR1', parts[0].to_i)
      end
    end
  rescue
    # don't die because of stupid exceptions
    nil
  end

  sleep 30
end