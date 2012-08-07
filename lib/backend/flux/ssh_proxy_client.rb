class SSHProxyClient
  def initialize(port)
    @port = port
  end
  
  def exec!(cmd)
    sock = TCPSocket.new 'localhost', @port
    sock.puts Oj.dump({ type: 'ssh', cmd: cmd })
    puts response = sock.gets
    sock.close
    response
  end
end