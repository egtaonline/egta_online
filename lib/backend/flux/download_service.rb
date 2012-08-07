class DownloadService
  def initialize(port, destination="#{Rails.root}/tmp/data")
    @port, @destination = port, destination
  end
  
  def download_simulation!(simulation)
    sock = TCPSocket.new 'localhost', @port
    sock.puts Oj.dump({ type: 'scp', cmd: 'download', src: "#{Yetting.deploy_path}/simulations/#{simulation.number}", destination: @destination })
    response = sock.gets
    sock.close
    if response != "\n" && response != "true"
      puts response
      simulation.fail "could not complete the transfer from remote host: #{response}.  Speak to Ben to resolve."
      return nil
    end
    "#{@destination}/#{simulation.number}"
  end
end