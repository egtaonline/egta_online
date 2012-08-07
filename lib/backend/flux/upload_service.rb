class UploadService
  def initialize(port)
    @port = port
  end
  
  def upload_simulation!(simulation, src_dir="#{Rails.root}/tmp/simulations")
    sock = TCPSocket.new 'localhost', @port
    sock.puts Oj.dump({ type: 'scp', cmd: 'upload', src: "#{src_dir}/#{simulation.number}", destination: "#{Yetting.deploy_path}/simulations" })
    response = sock.gets
    sock.close
    if response != "\n" && response != "true"
      puts response.inspect
      simulation.fail "could not complete the transfer to remote host: #{response}.  Speak to Ben to resolve."
      return nil
    end
    "#{Yetting.deploy_path}/simulations/#{simulation.number}"
  end
  
  def upload_simulator!(simulator)
    sock = TCPSocket.new 'localhost', @port
    sock.puts Oj.dump({ type: 'scp', cmd: 'upload', src: simulator.simulator_source.path, destination: "#{Yetting.deploy_path}/#{simulator.name}.zip" })
    response = sock.gets
    sock.close
    if response != "\n" && response != "true"
      puts response
      return nil
    end
    "#{Yetting.deploy_path}/#{simulator.name}.zip"
  end
end